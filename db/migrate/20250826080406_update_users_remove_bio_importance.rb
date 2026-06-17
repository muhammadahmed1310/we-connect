class UpdateUsersRemoveBioImportance < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :bio, :text
    remove_column :users, :importance, :integer
    remove_column :users, :engagement, :string
    remove_column :users, :classification_tags, :string
    remove_column :users, :is_deleted, :boolean
    remove_column :users, :is_active, :boolean
    add_column :users, :linkedin_url, :string
  end
end
