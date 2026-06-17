# One page in a survey
class SurveyPage < ApplicationRecord
  has_paper_trail

  belongs_to :survey
  has_many :survey_questions, dependent: :destroy

  acts_as_list scope: :survey

  def self.sub_records = %w[survey_questions]

  def self.table_names = %w[name survey_page_type]

  def self.field_names = %w[name survey_page_type title position content]
end
