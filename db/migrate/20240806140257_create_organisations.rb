class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :description
      t.string :organisation_type
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
