class AddCreatedByToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :created_by_id, :integer
  end
end
