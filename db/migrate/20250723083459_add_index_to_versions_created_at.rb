class AddIndexToVersionsCreatedAt < ActiveRecord::Migration[7.1]
  def change
    add_index :versions, :created_at
  end
end
