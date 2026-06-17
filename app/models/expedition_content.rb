class ExpeditionContent < ApplicationRecord
  belongs_to :expedition
  belongs_to :content

  def self.sub_records = %w[]

  def self.table_names = %w[name expedition content expedition_content_type]

  def self.table_edit_fields = %w[expedition_content_type]

  def self.field_names = %w[expedition content expedition_content_type]

  def name = "ExpeditionContent: #{expedition&.name} #{content&.name}"

end
