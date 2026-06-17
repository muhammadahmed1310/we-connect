class ChoiceItem < ApplicationRecord
  include PaperTrailCustom
  has_paper_trail save_object_changes: true

  def paper_trail_attributes_for_destroy
    { name: self.name }
  end
  belongs_to :choice
  acts_as_list scope: :choice
  has_many :user_role_types
  has_many :users, through: :user_role_types

  def self.sub_records = %w[]

  def self.table_names = %w[name position]

  def self.field_names = %w[name position created_at updated_at]

  def label
    name.titleize
  end

end
