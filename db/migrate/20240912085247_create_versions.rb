# This migration creates the `versions` table, the only schema PT requires.
# All other migrations PT provides are optional.
class CreateVersions < ActiveRecord::Migration[7.1]

  TEXT_BYTES = 1_073_741_823

  def change
    create_table :versions do |t|
      t.bigint   :whodunnit

      t.datetime :created_at, limit: 6

      t.bigint   :item_id,   null: false
      t.string   :item_type, null: false, limit: 191
      t.string   :event,     null: false
      t.text     :object, limit: TEXT_BYTES
    end
    add_index :versions, %i[item_type item_id]
  end
end
