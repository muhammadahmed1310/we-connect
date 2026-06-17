class CreateUserRoleTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :user_role_types do |t|
      t.references :user, null: false, foreign_key: true
      t.references :choice_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
