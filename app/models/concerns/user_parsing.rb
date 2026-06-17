module UserParsing
  extend ActiveSupport::Concern
  def self.parse_data(spreadsheet, current_user: nil, **_)
    current_user = current_user[:current_user] if current_user.is_a?(Hash) && current_user.key?(:current_user)
    sheet = spreadsheet.sheet('Total list')
    rows = sheet.parse(headers: true)

    # --- normalize & prune guide rows ---
    header_keys = rows.first&.keys&.map { |k| k.to_s.strip.downcase }
    rows = rows.reject do |row|
      vals = row.values.map { |v| v.to_s.strip }
      down = vals.map(&:downcase)

      blank_row = vals.all?(&:blank?)
      looks_like_headers = header_keys && down.any? && down.all? { |v| v.blank? || header_keys.include?(v) }
      placeholder_email = row['Email Address'].to_s.strip =~ /\Aemail(\s*address)?\z/i

      blank_row || looks_like_headers || placeholder_email
    end

    errors  = []
    created = []
    updated = []

    # -------------------------
    # Phase 1: Validation
    # -------------------------
    rows.each_with_index do |row, i|
      row_number = i + 2
      email = row['Email Address']&.strip
      name  = "#{row['First Name']} #{row['Last Name']}".strip

      next if [email, row['First Name'], row['Last Name']].all?(&:blank?) # skip totally empty lines that slipped through

      if email.blank?
        errors << "[Row #{row_number}] #{name}: Missing email"
        next
      end

      if row['First Name'].blank?
        errors << "[Row #{row_number}] #{email}: Missing First Name"
        next
      end

      unless email =~ /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
        errors << "[Row #{row_number}] #{email}: Invalid email format"
      end

      begin
        Organisation.find_or_create_by!(name: row['Organisation']&.strip.presence || 'Unknown')
      rescue => e
        errors << "[Row #{row_number}] #{email}: Failed to create/find organisation - #{e.message}"
      end
    end

    return { success: false, message: 'Validation failed. Fix errors and re-upload.', errors: errors, created: [] } if errors.any?

    # -------------------------
    # Phase 2: Transactional Save
    # -------------------------
    ActiveRecord::Base.transaction do
      rows.each_with_index do |row, i|
        row_number = i + 2
        email = row['Email Address']&.strip
        next if email.blank?

        # Find existing (case-insensitive) or seed a new one with email set
        user = User.find_by('LOWER(email) = ?', email.downcase) || User.new(email: email)
        is_new = user.new_record?
        user.created_by ||= current_user if is_new

        # snapshots BEFORE changes
        old_attrs     = user.attributes.slice('first_name','last_name','country','nationality','phone','job_title','notes')
        old_roles     = user.user_role_types.map(&:name).sort.dup
        old_org_names = user.organisations.pluck(:name).sort

        # Resolve/ensure org record now (no join yet)
        org = Organisation.find_or_create_by!(name: row['Organisation']&.strip.presence || 'Unknown')

        # ---- assign ALL user fields (including is_contact_only) BEFORE any save ----
        fields = {
          first_name:       row['First Name']&.strip,
          last_name:        row['Last Name']&.strip,
          country:          row['Location']&.strip,
          nationality:      row['Nationality']&.strip,
          phone:            row['Contact Number'],
          job_title:        row['Job Title']&.strip.presence || 'Member',
          notes:            row['Notes']&.strip,
          is_contact_only:  true
        }
        user.assign_attributes(fields.compact)

        # This save now bypasses login-password/country/nationality requirements (contact-only)
        unless user.save
          raise ActiveRecord::Rollback, "[Row #{row_number}] #{email}: #{user.errors.full_messages.join(', ')}"
        end

        # Link organisation AFTER the user has an id
        OrganisationUser.find_or_create_by!(user_id: user.id, organisation_id: org.id)

        # Roles (append only)
        roles  = (row['Role'] || '').split(',').map(&:strip)
        choice = Choice.find_by(name: 'user_role_type')
        if roles.any? && choice
          ChoiceItem.where(choice: choice, name: roles).each do |role_item|
            user.user_role_choice_items.find_or_create_by!(choice_item: role_item) unless user.user_role_types.include?(role_item)
          end
        end

        # snapshots AFTER changes
        new_attrs     = user.attributes.slice('first_name','last_name','country','nationality','phone','job_title','notes')
        new_roles     = user.user_role_types.reload.map(&:name).sort
        new_org_names = user.organisations.reload.pluck(:name).sort

        # diffs
        attr_diffs = {}
        new_attrs.each { |k,v| ov = old_attrs[k]; attr_diffs[k] = { from: ov, to: v } unless ov == v }
        role_diff_changed = old_roles != new_roles

        if is_new
          created << { id: user.id, name: user.name, type: 'User', role: new_roles.join(', ') }
        elsif attr_diffs.any? || role_diff_changed || old_org_names != new_org_names
          from_data = attr_diffs.transform_values { |v| v[:from] }
          to_data   = attr_diffs.transform_values { |v| v[:to] }
          if role_diff_changed
            from_data['Role'] = old_roles
            to_data['Role']   = new_roles
          end
          if old_org_names != new_org_names
            from_data['Organisations'] = old_org_names
            to_data['Organisations']   = new_org_names
          end
          updated << { id: user.id, name: user.name, type: 'User', role: new_roles.join(', '), from: from_data, to: to_data }
        end
      end
    rescue => e
      errors << e.message
      raise ActiveRecord::Rollback
    end

    # -------------------------
    # Log PaperTrail
    # -------------------------
    if errors.any?
      return { success: false, message: 'Upload aborted due to errors', errors: errors, created: [], updated: [] }
    end

    if created.any? || updated.any?
      first_record = (created.first || updated.first)
      PaperTrail::Version.create!(
        item_type: 'User',
        event: 'bulk_upload',
        item_id: first_record[:id],
        object: {
          action: 'batch_users_upload',
          records: created + updated
        }.to_json,
        whodunnit: current_user.is_a?(User) ? current_user.id : current_user[:id]
      )
    end

    {
      success: true,
      message: "#{created.size} created, #{updated.size} updated",
      created: created,
      updated: updated
    }
  end
end
