# A question on a survey page.
#
# The question can be of various types, including multiple choice, text, and numeric.
class SurveyQuestion < ApplicationRecord
  has_paper_trail

  belongs_to :survey_page
  belongs_to :choice, optional: true
  has_many :survey_answers, dependent: :destroy
  has_many :survey_responses, through: :survey_answers

  delegate :survey, to: :survey_page

  acts_as_list scope: :survey_page

  def self.sub_records = %w[survey_responses]

  def self.table_names = %w[name survey_question_item_type]

  def self.field_names = %w[name label survey_question_item_type question_class text_lines
                            min_value max_value choice_name multiple_answers hint position notes]

end
