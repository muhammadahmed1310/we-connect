class CreateExpeditionSurveys < ActiveRecord::Migration[7.1]
  def change
    create_table :expedition_surveys do |t|
      t.references :expedition, null: false, foreign_key: true
      t.bigint :user_id
      t.string :title
      t.text :content  #to be changed later

      t.timestamps
    end
  end
end
