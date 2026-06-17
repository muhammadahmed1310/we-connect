class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.belongs_to :expedition
      t.belongs_to :expedition_phase
      t.belongs_to :location
      t.string :name
      t.references :activity_type, foreign_key: { to_table: :choice_items }
      t.references :activity_status_type, foreign_key: { to_table: :choice_items }
      t.integer :assigned_user_id
      t.string :description
      t.text :notes
      t.date :start_date
      t.date :deadline_date
      t.integer :position
      t.boolean :is_completed, default: false, null: false
      t.timestamps
    end
  end
end
