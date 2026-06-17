class CreateExpeditionOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_organisations do |t|
      t.belongs_to :expedition
      t.belongs_to :organisation
      t.string :expedition_organisation_type

      t.boolean :is_active, default: true, null: false
      t.timestamps
    end
  end
end
