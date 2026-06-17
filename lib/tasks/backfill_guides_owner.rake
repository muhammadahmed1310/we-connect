namespace :we do
  desc "Backfill Guides -> owner to Funmi and closed-to-outreach. Supports FORCE and filters."
  task backfill_guides_owner: :environment do
    force          = ENV["FORCE"].to_s == "1"               # FORCE=1 to overwrite existing owners/flags
    contacts_only  = ENV["CONTACTS_ONLY"].to_s == "1"       # CONTACTS_ONLY=1 to scope to is_contact_only users
    exclude_roles  = (ENV["EXCLUDE_ROLES"] || "").split(",").map { |s| s.strip.downcase }.reject(&:blank?)
    # Quick helper toggle: EXCLUDE_STEERING=1 will add "steering group" to the exclusion list
    exclude_roles << "steering group" if ENV["EXCLUDE_STEERING"].to_s == "1"

    funmi = User.find_by('LOWER(email) = ?', 'funmi.adeyemi@womenemerging.org')
    abort "Funmi not found (funmi.adeyemi@womenemerging.org)" unless funmi
    puts "✅ Owner target: Funmi => ##{funmi.id} (#{funmi.full_name})"

    crt = Choice.find_by(name: 'user_role_type') or abort "Choice 'user_role_type' not found"
    guide_item_ids = ChoiceItem.where(choice_id: crt.id)
                               .where('LOWER(name) IN (?)', %w[guide guides])
                               .pluck(:id)
    abort "No 'guide/guides' items under user_role_type" if guide_item_ids.empty?
    puts "✅ Guide role item IDs: #{guide_item_ids.inspect}"

    scope = User.joins(user_role_choice_items: { choice_item: :choice })
                .where(choices: { name: 'user_role_type' })
                .where(user_role_choice_items: { choice_item_id: guide_item_ids })
                .distinct

    scope = scope.where(is_contact_only: true) if contacts_only

    if exclude_roles.any?
      # Exclude users who ALSO have any of the excluded roles
      excluded_ids = User.joins(user_role_choice_items: { choice_item: :choice })
                         .where(choices: { name: 'user_role_type' })
                         .where('LOWER(choice_items.name) IN (?)', exclude_roles)
                         .distinct
                         .pluck(:id)
      scope = scope.where.not(id: excluded_ids)
      puts "ℹ️ Excluding users who have any of: #{exclude_roles.join(', ')} (#{excluded_ids.size} user(s) excluded)"
    end

    total = scope.count
    puts "🔎 Matched #{total} Guide user(s)#{' (contacts only)' if contacts_only}."

    # Reporting buckets
    with_nil_owner   = scope.where(owner_id: nil).count
    owner_not_funmi  = scope.where.not(owner_id: [nil, funmi.id]).count
    closed_nil       = scope.where(is_contact_restricted: nil).count
    closed_false     = scope.where(is_contact_restricted: false).count
    puts "   • owner_id is NULL:     #{with_nil_owner}"
    puts "   • owner != Funmi:       #{owner_not_funmi}"
    puts "   • closed flag is NULL:  #{closed_nil}"
    puts "   • closed flag = false:  #{closed_false}"

    updated = 0
    scope.find_each do |u|
      before_owner = u.owner_id
      before_flag  = u.is_contact_restricted

      if force
        u.owner_id = funmi.id
        u.is_contact_restricted = true
      else
        u.owner_id ||= funmi.id
        u.is_contact_restricted = true if u.is_contact_restricted.nil?
      end

      next unless u.changed?

      u.save!(validate: false)
      updated += 1
      puts "  • Updated ##{u.id} #{u.full_name} "\
             "(owner #{before_owner.inspect}→#{u.owner_id}, closed #{before_flag.inspect}→#{u.is_contact_restricted})"
    end

    puts "✅ Backfill complete. Updated #{updated}/#{total} user(s)."
    puts "   Tip: add FORCE=1 to override existing owners/closed flags."
    puts "        add EXCLUDE_STEERING=1 or EXCLUDE_ROLES='steering group, ambassadors' to skip certain roles."
    puts "        add CONTACTS_ONLY=1 to limit to contact-only users."
  end
end
