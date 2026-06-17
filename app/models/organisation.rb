# Organisations are all the various companies and other organisations we work with.
#
# * Users in the system can be associated with an organisation and can optionally
#   have a role that allows them to manage the organisation.
# * Expeditions can be associated with one or more organisations and have various roles
#   such as funder, sponsor, etc.
# * Organisations also associated locations.
class Organisation < ApplicationRecord
  include Scopable
  include PaperTrailCustom
  has_paper_trail save_object_changes: true
  include Searchable
  searchable_columns :name, :organisation_type
  def paper_trail_attributes_for_destroy
    { name: self.name }
  end
  has_many :expedition_organisations, dependent: :destroy
  has_many :locations, dependent: :destroy

  has_many :organisation_users, dependent: :destroy
  has_many :users, through: :organisation_users
  has_many :expeditions, through: :expedition_organisations

  validates :name, presence: true

  we_scopes :organisation_type, :is_active
  before_validation :normalize_name

  validate :name_unique_ci_squished

  def self.field_names = %w[name description organisation_type]
  def self.table_names = %w[name organisation_type]
  def self.sub_records = %w[users expedition_organisations]
  private
  def normalize_name
    self.name = name.to_s.squish
  end
  def name_unique_ci_squished
    return if name.blank?
    exists = Organisation.where("LOWER(name) = ?", name.downcase).where.not(id: id).exists?
    errors.add(:name, "already exists") if exists
  end
end
