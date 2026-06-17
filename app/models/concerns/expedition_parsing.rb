module ExpeditionParsing
  extend ActiveSupport::Concern

  def self.parse_data(spreadsheet, current_user: nil, **_)
    current_user = current_user[:current_user] if current_user.is_a?(Hash) && current_user.key?(:current_user)

    all_errors = []
    validated_data = []

    spreadsheet.sheets.each do |sheet|
      sheet_data = spreadsheet.sheet(sheet).parse
      expedition_info, user_rows, errors = validate_sheet(sheet, sheet_data)
      all_errors += errors
      validated_data << {sheet:, expedition_info:, user_rows:} if errors.empty?
    end

    if all_errors.any?
      # 🔹 Limit what goes into the flash to avoid CookieOverflow
      displayed_errors = all_errors.first(20)
      extra_count = all_errors.size - displayed_errors.size

      summary = "Upload failed. #{all_errors.size} issues found."
      summary << " Showing first #{displayed_errors.size} only; there are #{extra_count} more..." if extra_count > 0

      return {
        success: false,
        message: "#{summary}\n- #{displayed_errors.join("\n- ")}",
        errors: all_errors
      }
    end

    created_entities = []
    updated_entities = []

    # Only save if all sheets passed validation
    Expedition.transaction do
      validated_data.each do |data|
        expedition = create_or_update_expedition(data[:expedition_info], current_user, created_entities, updated_entities)
        create_expedition_associations(expedition, expedition.id, data[:expedition_info], created_entities)
        parse_users(data[:user_rows], expedition, expedition.id, current_user, created_entities, updated_entities)
      end
    end
    first_expedition = created_entities.find { |e| e[:type] == 'Expedition' } ||
      updated_entities.find { |e| e[:type] == 'Expedition' }
    if first_expedition
      PaperTrail::Version.create!(
        item_type: 'Expedition',
        event: 'bulk_create',
        item_id: first_expedition[:id],
        object: {action: 'expedition_excel_upload', records: created_entities + updated_entities}.to_json,
        whodunnit: current_user.is_a?(User) ? current_user.id : current_user[:id]
      )
    end
    {
      success: true,
      message: "#{created_entities.size} created, #{updated_entities.size} updated",
      created: created_entities,
      updated: updated_entities
    }
  rescue => e
    Rails.logger.error("Upload failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    {success: false, message: "Upload failed: #{e.message}"}
  end

    # -----------------------
  # VALIDATION PHASE
  # -----------------------

  def self.normalize_email(raw)
    raw.to_s
       .unicode_normalize(:nfkc)
       .gsub("\u00A0", ' ')      # non-breaking space -> normal space
       .gsub(/[[:space:]]+/, ' ')
       .strip
  end
  def self.valid_email_format?(email)
    # Very simple format check: something@something.something
    !!(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/.match(email))
  end

  def self.validate_sheet(sheet, data)
    errors = []
    expedition_info = {}
    user_rows = []

    user_table_index = data.index { |row| row[0].to_s.strip == 'First Name' }

    if user_table_index.nil?
      errors << "#{sheet}: No 'First Name' header found to start user table"
      return [expedition_info, user_rows, errors]
    end

    # Collect expedition info (rows before user table)
    data[0...user_table_index].each_with_index do |row, i|

      expedition_info[:name] ||= row[0].to_s.strip
      expedition_info[:partner_names] ||= []
      expedition_info[:expedition_type] ||= row[2].to_s.strip
      expedition_info[:expedition_phase_type] ||= row[4].to_s.strip
      expedition_info[:start_date] ||= row[5]
      expedition_info[:end_date] ||= row[6]
      expedition_info[:funded_amount] ||= row[7]
      expedition_info[:location] ||= row[9].to_s.strip

      expedition_info[:partner_names] << row[1].to_s.strip if row[1].present?
      expedition_info[:leader_names] ||= []
      expedition_info[:leader_names] << row[3].to_s.strip if row[3].present?
      expedition_info[:manager_names] ||= []
      expedition_info[:manager_names] << row[8].to_s.strip if row[8].present?
    end

    expedition_label = expedition_info[:name].presence || "[Unnamed Expedition]"

    # Validate expedition info
    errors << "#{sheet}: Expedition '#{expedition_label}' is missing a name" if expedition_info[:name].blank?
    errors << "#{sheet}: Expedition '#{expedition_label}' is missing expedition type" if expedition_info[:expedition_type].blank?
    errors << "#{sheet}: Expedition '#{expedition_label}' is missing phase type" if expedition_info[:expedition_phase_type].blank?
    errors << "#{sheet}: Expedition '#{expedition_label}' is missing start or end date" if expedition_info[:start_date].blank? || expedition_info[:end_date].blank?

    # Partner orgs
    expedition_info[:partner_names].each do |p|
      next if p.blank?

      org = Organisation.find_or_create_by(name: p) # <-- create if missing
      expedition_info[:partner_names].map!(&:strip) # ensure clean names
    end
    # Leaders and Managers
    (expedition_info[:leader_names] + expedition_info[:manager_names]).each do |name|
      fn, ln = name.to_s.strip.split(' ', 2)
      errors << "#{sheet}: Expedition '#{expedition_label}' references unknown user: '#{name}'" unless User.exists?(first_name: fn, last_name: ln)
    end


    # Collect and validate user rows
    user_rows = data[(user_table_index + 1)..].reject { |r| r.compact.empty? }

    # Validate users
    user_rows.each_with_index do |row, idx|
      fname = row[0].to_s.strip
      lname = row[1].to_s.strip
      raw_email = row[4].to_s.strip
      email     = normalize_email(raw_email)
      role = row[8].to_s.strip

      label = [fname, lname].compact.join(' ')
      label = email if label.blank?

      sheet_row_number = user_table_index + 2 + idx + 1 # +2 for header and 1-based index

      errors << "#{sheet} [User Row #{sheet_row_number} - #{label}]: First name is missing" if fname.blank?
      if email.blank?
        errors << "#{sheet} [User Row #{sheet_row_number} - #{label}]: Email is missing"
      elsif !valid_email_format?(email)
        errors << "#{sheet} [User Row #{sheet_row_number} - #{label}]: "\
          "Email '#{email}' appears invalid. Please check the spelling and remove extra spaces."
      end


      if role.present?
        role_item = ChoiceItem.joins(:choice).find_by("LOWER(choice_items.name) = ? AND choices.name = 'user_role_type'", role.downcase)
        errors << "#{sheet} [User Row #{sheet_row_number} - #{label}]: Role '#{role}' is invalid" if role_item.nil?
      end
    end

    [expedition_info, user_rows, errors]
  end

  # -----------------------
  # CREATION PHASE
  # -----------------------
  def self.create_or_update_expedition(info, current_user, created, updated)
    raise "Missing expedition name" if info[:name].blank?

    # 1. Find skeleton to clone from
    skeleton = Expedition.find_by(name: info[:expedition_type], is_skeleton: true)
    raise "Skeleton not found for expedition type '#{info[:expedition_type]}'" if skeleton.nil?

    # 2. Check if expedition already exists
    expedition = Expedition.find_by(name: info[:name])

    if expedition
      # Existing expedition: update attributes
      expedition.update!(
        expedition_type: info[:expedition_type],
        expedition_phase_type: info[:expedition_phase_type],
        start_date: info[:start_date],
        end_date: info[:end_date],
        funded_amount: info[:funded_amount],
        location: info[:location]
      )
      updated << { id: expedition.id, name: expedition.name, type: 'Expedition' }
    else
      # New expedition: clone from skeleton
      expedition = Expedition.create_from_skeleton(
        info[:name],
        info[:start_date],
        info[:end_date],
        skeleton,
        {
          funded_amount: info[:funded_amount],
          location: info[:location],
          expedition_type: info[:expedition_type],
          expedition_phase_type: info[:expedition_phase_type]
        },
        current_user
      )
      created << { id: expedition.id, name: expedition.name, type: 'Expedition' }
    end

    expedition
  end


  def self.create_expedition_associations(expedition, expedition_id, info, created_entities)
    Rails.logger.info("Creating expedition: #{info[:name]}")
    info[:partner_names].each do |p|
      org = Organisation.find_by(name: p)
      next unless org

      eo = ExpeditionOrganisation.find_or_create_by!(
        expedition_id: expedition_id,
        organisation_id: org.id,
        expedition_organisation_type: 'partner'
      )
      created_entities << {id: eo.id, name: org.name, type: 'Organisation'}
    end

    {'leader' => info[:leader_names], 'manager' => info[:manager_names]}.each do |role, names|
      names.each do |full_name|
        parts = full_name.to_s.strip.split
        fn = parts[0]
        ln = parts[1..].join(' ')
        user = User.find_by(first_name: fn, last_name: ln)
        raise "User not found for name #{full_name}" if user.nil?
        unless user
          Rails.logger.warn("Skipped creating expedition_user for missing #{role}: '#{full_name}' in expedition #{expedition_id}")
          next
        end

        eu = ExpeditionUser.find_or_create_by!(expedition_id:, user_id: user.id)
        eu.update!(expedition_role_type: role) if eu.expedition_role_type != role
        created_entities << {
          id: eu.id,
          name: user.name,
          type: 'User',
          expedition_name: expedition.name,
          expedition_id: expedition_id,
          role: role,
          from: nil,
          to: nil
        }

      end
    end
  end

  def self.parse_users(rows,expedition, expedition_id, current_user, created_entities, updated_entities)
    rows.each_with_index do |row, i|
      org_name = row[2].to_s.strip.presence || 'Unknown'
      org = Organisation.find_or_create_by(name: org_name)
      raw_email = row[4]
      email     = normalize_email(raw_email)

      fname = row[0].to_s.strip
      lname = row[1].to_s.strip
      label = [fname, lname].reject(&:blank?).join(' ')
      label = email if label.blank?
      sheet_row_number = i + 1 # “row in user table”; validation phase already has exact Excel row

      # Extra safety – if email somehow is blank here, bail with a CLEAR error
      if email.blank?
        raise StandardError,
              "Invalid user row in expedition '#{expedition.name}': "\
                "Email is blank for '#{label}' (user table row #{sheet_row_number}). "\
                "Please fill in a valid email and re-upload."
      end


      user = User.find_by('LOWER(email) = ?', email.downcase) || User.new(email: email)
      user.assign_attributes(
        first_name: row[0].to_s.strip,
        last_name: row[1].to_s.strip,
        phone: row[3].to_s.strip,
        country: row[5].to_s.strip,
        nationality: row[6].to_s.strip,
        job_title: row[7].to_s.strip.presence || 'member',
        is_contact_only: true
      )


      # ✅ Safely attach organisation if the association exists
      if org && user.respond_to?(:organisations)
        user.organisations << org unless user.organisations.exists?(org.id)
      elsif org && user.respond_to?(:organisation=)
        # fallback in case you *do* still have belongs_to :organisation somewhere
        user.organisation = org
      end

      user.created_by ||= current_user if user.new_record?
      begin
        user.save! if user.changed?  # 🔹 unchanged existing users are skipped quietly
      rescue ActiveRecord::RecordInvalid => e
        # Turn AR’s vague message into a very specific one
        raise StandardError,
              "Failed to save user for expedition '#{expedition.name}': " \
                "[User table row #{sheet_row_number} - #{label} / '#{email}'] – " \
                "#{e.record.errors.full_messages.join(', ')}"
      end

      if user.previous_changes.any?
        changes = user.previous_changes.except(:updated_at)
        unless user.previously_new_record?
          updated_entities << {
            id: user.id,
            name: user.name,
            type: 'User',
            expedition_name: expedition.name,
            expedition_id: expedition.id,
            from: changes.transform_values(&:first),
            to: changes.transform_values(&:last)
          }
        end
      end

      role = row[8].to_s.strip
      if role.present?
        role_item = ChoiceItem.joins(:choice).find_by("LOWER(choice_items.name) = ? AND choices.name = 'user_role_type'", role.downcase)
        unless role_item
          Rails.logger.warn("Invalid role '#{role}' for user #{user.name} in expedition #{expedition_id}")
          next
        end
        user.user_role_choice_items.find_or_create_by!(choice_item_id: role_item.id) unless user.user_role_types.include?(role_item)
      end


      eu = ExpeditionUser.find_or_initialize_by(expedition_id:, user_id: user.id)
      old_role = eu.expedition_role_type_was
      if eu.expedition_role_type != role
        eu.expedition_role_type = role
      end

      begin
        eu.save!
      rescue ActiveRecord::RecordInvalid => e
        raise StandardError,
              "Failed to link '#{email}' to expedition '#{expedition.name}': " \
                "#{e.record.errors.full_messages.join(', ')}"
      end

      if eu.previous_changes.any?
        if eu.previously_new_record?
          created_entities << {
            id: eu.id,
            name: user.name,
            type: 'User',
            expedition_name: expedition.name,
            expedition_id: expedition.id,
            role: role,
            from: nil,
            to: nil
          }
        else
          updated_entities << {
            id: eu.id,
            name: user.name,
            type: 'User',
            expedition_name: expedition.name,
            expedition_id: expedition.id,
            from: [old_role],
            to: [role]
          }
        end
      end

    end
  end
end