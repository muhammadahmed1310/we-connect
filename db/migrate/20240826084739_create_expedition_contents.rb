class CreateExpeditionContents < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_contents do |t|
      t.belongs_to :expedition
      t.belongs_to :content
      t.string :expedition_content_type

      t.timestamps
    end
  end
end
