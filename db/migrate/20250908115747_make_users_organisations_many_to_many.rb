# db/migrate/20250908_000001_make_users_organisations_many_to_many.rb
class MakeUsersOrganisationsManyToMany < ActiveRecord::Migration[7.1]
  def up
    create_table :organisation_users do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :user,         null: false, foreign_key: true
      t.timestamps
    end
    add_index :organisation_users, [:organisation_id, :user_id], unique: true

    # Backfill from users.organisation_id -> organisation_users
    if column_exists?(:users, :organisation_id)
      say_with_time "Backfilling organisation_users from users.organisation_id" do
        execute <<~SQL
          INSERT IGNORE INTO organisation_users (organisation_id, user_id, created_at, updated_at)
          SELECT organisation_id, id, NOW(), NOW()
          FROM users
          WHERE organisation_id IS NOT NULL
        SQL
      end
      remove_foreign_key :users, :organisations rescue nil
      remove_column :users, :organisation_id
    end
  end

  def down
    add_column :users, :organisation_id, :bigint
    add_foreign_key :users, :organisations
    drop_table :organisation_users
  end
end
