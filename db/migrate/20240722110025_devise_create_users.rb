# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.belongs_to :organisation
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :country
      t.string :nationality
      t.date :birth_date
      t.string :industry_type
      t.string :organisation_user_role_type, default: 'member'
      t.text :bio
      t.string :job_title
      t.string :assistant_email
      t.string :engagement
      t.string :classification_tags
      t.integer :importance
      t.boolean :is_contact_only, default: false
      t.boolean :is_active, default: true
      t.boolean :is_deleted, default: false
      t.text :notes

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
