class CreateExpeditionUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_users do |t|
      t.belongs_to :expedition
      t.belongs_to :user
      t.string :expedition_role_type
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
