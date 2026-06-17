# db/migrate/20250826_add_owner_and_contact_permission_to_users.rb
class AddOwnerAndContactPermissionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :owner, foreign_key: { to_table: :users }  # who owns this contact
    add_column    :users, :is_contact_restricted, :boolean, default: false, null: false
    add_index     :users, :is_contact_restricted
  end
end
