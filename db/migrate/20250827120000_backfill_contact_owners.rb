# db/migrate/20250827120000_backfill_contact_owners.rb
class BackfillContactOwners < ActiveRecord::Migration[7.1]
  def up
    mia = User.find_by(email: 'mia.haug@womenemerging.org')
    return unless mia

    User.where(is_contact_only: true, owner_id: nil).find_each do |u|
      u.update_columns(owner_id: mia.id) # skip validations/callbacks
    end
  end

  def down
    # no-op (we don't want to unset owners)
  end
end
