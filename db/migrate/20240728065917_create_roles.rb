class CreateRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :roles do |t|
      t.string :name
      t.boolean :is_active

      t.timestamps
    end

    create_table :user_roles do |t|
      t.belongs_to :role
      t.belongs_to :user
    end
  end
end
