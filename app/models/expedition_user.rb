class ExpeditionUser < ApplicationRecord
  include Searchable

  belongs_to :user
  belongs_to :expedition

  # Fields on expedition_users
  searchable_columns :expedition_role_type

  # Fields on associated tables (must be real DB columns)
  searchable_association :user, :first_name, :last_name, :email
  searchable_association :expedition, :name

  # Optional: make the global q=... search work nicely for full name/email/role/expedition
  def self.apply_search(scope, term)
    return scope if term.blank?
    like = "%#{term.strip}%"
    scope
      .joins(:user, :expedition)
      .where(
        "CONCAT(users.first_name,' ',users.last_name) LIKE :q
         OR users.first_name LIKE :q
         OR users.last_name  LIKE :q
         OR users.email      LIKE :q
         OR expedition_users.expedition_role_type LIKE :q
         OR expeditions.name LIKE :q",
        q: like
      )
      .distinct
  end

  scope :leaders,      -> { where(expedition_role: 'leader') }
  scope :participants, -> { where(expedition_role: 'participant') }

  def name
    "ExpeditionUser: #{expedition&.name} #{user&.name}"
  end

  def user_name
    "#{user&.first_name} #{user&.last_name}"
  end

  def self.sub_records         = %w[]
  def self.table_names         = %w[user expedition_role_type]
  def self.table_edit_fields   = %w[expedition_role_type]
  def self.field_names         = %w[expedition user expedition_role_type]
  def self.search_fields       = ['expedition_users.expedition_role_type', 'users.first_name', 'users.last_name']
end
