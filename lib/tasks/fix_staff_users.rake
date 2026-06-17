# lib/tasks/fix_staff_users.rake
namespace :users do
  desc "Fix staff/admin users accidentally turned into contacts; set login + default password"
  task fix_staff_contacts: :environment do
    env_confirm = ENV["CONFIRM"] || ""
    unless %w[staging STAGING].include?(env_confirm) || Rails.env.staging?
      puts "❌ Refusing to run. Set CONFIRM=staging to proceed on staging."
      puts "   Example: CONFIRM=staging DRY_RUN=1 bin/rails users:fix_staff_contacts"
      exit 1
    end

    dry_run   = ENV["DRY_RUN"] == "1"
    force_pw  = ENV["FORCE_PW"] == "1"   # overwrite password even if already present
    default_pw = ENV["PW"].presence || "123456"

    scope = User.staff_or_admin.where(is_contact_only: true)
    total = scope.count
    puts "🔎 Found #{total} staff/admin user(s) marked as contact."

    fixed = 0
    skipped = 0
    errors = 0

    # Make PaperTrail attribute sane
    PaperTrail.request.whodunnit = "system:fix_staff_contacts"

    scope.find_each(batch_size: 200) do |u|
      begin
        changes = {}

        # flip to login user
        changes[:is_contact_only] = [u.is_contact_only, false] if u.is_contact_only

        # remove owner (requested)
        changes[:owner_id] = [u.owner_id, nil] if u.owner_id.present?

        # password: only if missing OR forced
        needs_pw = u.encrypted_password.blank? || force_pw
        if needs_pw
          u.password = default_pw
          u.password_confirmation = default_pw
          changes[:encrypted_password] = ["<redacted>", "<redacted>"]
        end

        if changes.empty?
          skipped += 1
          puts "• SKIP #{u.id} #{u.email} (no change needed)"
          next
        end

        if dry_run
          puts "DRY-RUN → would update #{u.id} #{u.email}: #{changes.keys.join(', ')}"
          next
        end

        # Skip validations:
        # - owner presence (unconditional) would block clearing owner_id
        # - country/nationality requirements for login users could also block save
        u.is_contact_only = false                       if u.is_contact_only
        u.owner_id        = nil                         if u.owner_id.present?
        # Devise hashes on assignment above
        u.save!(validate: false)

        fixed += 1
        puts "✔ FIXED #{u.id} #{u.email}"
      rescue => e
        errors += 1
        puts "⚠️ ERROR #{u.id} #{u.email}: #{e.class} - #{e.message}"
      end
    end

    puts "———"
    puts "Done. Fixed: #{fixed}, Skipped: #{skipped}, Errors: #{errors} (Total scanned: #{total})"
    puts "Password used: #{default_pw.inspect}#{' (forced overwrite)' if force_pw}"
  end
end
