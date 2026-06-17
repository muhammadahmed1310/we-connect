class ExpeditionOrganisation < ApplicationRecord
  belongs_to :expedition
  belongs_to :organisation

  scope :funders, -> { where(expedition_organisation_role: 'funder') }
  scope :sponsors, -> { where(expedition_organisation_role: 'sponsor') }

  def self.sub_records = %w[]

  def self.table_names = %w[expedition organisation expedition_organisation_type]

  def self.table_edit_fields = %w[expedition_organisation_type]

  def self.field_names = %w[expedition organisation expedition_organisation_type]

  def name = "ExpeditionOrganisation: #{expedition&.name} #{organisation&.name}"
end
