class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.belongs_to :organisation
      t.string :name
      t.string :description
      t.string :location_type
      t.string :address
      t.string :city
      t.string :country
      t.string :postal_code
      t.string :phone
      t.string :longitude
      t.string :latitude

      t.timestamps
    end
  end
end
