class CreateActivityContents < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_contents do |t|
      t.belongs_to :activity
      t.belongs_to :content
      t.string :activity_content_type

      t.timestamps
    end
  end
end
