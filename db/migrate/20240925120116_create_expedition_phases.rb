class CreateExpeditionPhases < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_phases do |t|
      t.belongs_to :expedition
      t.string :name
      t.date :start_date
      t.date :end_date
      t.boolean :is_completed

      t.timestamps
    end
  end
end
