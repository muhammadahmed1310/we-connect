class CreateLogRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :log_records do |t|
      t.datetime :datetime
      t.string :event_type
      t.text :message
      t.string :rails_env

      t.timestamps
    end
  end
end
