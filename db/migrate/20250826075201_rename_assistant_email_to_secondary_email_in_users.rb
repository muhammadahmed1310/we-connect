# db/migrate/20250826084500_rename_assistant_email_to_secondary_email_in_users.rb
class RenameAssistantEmailToSecondaryEmailInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :assistant_email, :secondary_email
  end
end
