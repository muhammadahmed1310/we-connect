class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents do |t|
      t.string :name
      t.string :description
      t.string :content_type
      t.text :content
      t.integer :author_id


      t.boolean :is_active, default: false
      t.boolean :is_published, default: false
      t.boolean :is_sent, default: false

      t.timestamps
    end
  end
end
