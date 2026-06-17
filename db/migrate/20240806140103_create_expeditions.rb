class CreateExpeditions < ActiveRecord::Migration[7.1]
  def change
    create_table :expeditions do |t|
      t.string :name
      t.string :expedition_type
      t.date :start_date
      t.date :end_date
      t.string :expedition_phase_type
      t.integer :funded_amount
      t.integer :progress
      t.string :location
      t.boolean :is_platform_created, default: false, null: false
      t.boolean :is_marketing_completed, default: false, null: false
      t.boolean :is_ip_agreement_signed, default: false, null: false
      t.boolean :is_impact_survey_completed, default: false, null: false
      t.boolean :is_member_agreement_completed, default: false, null: false
      t.boolean :is_skeleton, default: false, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_approved, default: false, null: false
      t.text :description
      t.timestamps

    end
  end
end
