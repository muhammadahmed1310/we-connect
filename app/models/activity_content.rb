class ActivityContent < ApplicationRecord
  belongs_to :activity
  belongs_to :content

  def self.sub_records = %w[]

  def self.table_names = %w[name activity content activity_content_type]

  def self.table_edit_fields = %w[activity_content_type]

  def self.field_names = %w[name activity content activity_content_type]

  def name = "ActivityLocation: #{activity&.name} #{content&.name}"

end
