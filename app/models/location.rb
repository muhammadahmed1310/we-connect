# A location is a physical place.
#
# * It is usually associated with an organization
# * It can also be associated with expeditions and activities
#
# CJR Finish - are these also associated with users?
class Location < ApplicationRecord
  has_paper_trail

  belongs_to :organisation, optional: true

  has_many :activities, dependent: :nullify
  has_many :expeditions, dependent: :nullify

  validates :name, presence: true

  def self.table_names = %w[name location_type organisation_id]

  def self.field_names = %w[name description]

  def self.sub_records = %w[expeditions activities]

end
