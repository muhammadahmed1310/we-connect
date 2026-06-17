class CreateChoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :choice_items do |t|
      t.belongs_to :choice, null: false
      t.string :name
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
