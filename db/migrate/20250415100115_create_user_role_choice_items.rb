class CreateUserRoleChoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :user_role_choice_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :choice_item, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_role_choice_items, [:user_id, :choice_item_id], unique: true

  end
end
