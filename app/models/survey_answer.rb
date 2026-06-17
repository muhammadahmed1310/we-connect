class SurveyAnswer < ApplicationRecord
  has_paper_trail

  belongs_to :survey_question
  belongs_to :survey_response

  delegate :survey_page, to: :survey_question
  delegate :survey, to: :survey_page
  delegate :user, to: :survey_response

  def self.sub_records = %w[]

  def self.table_names = %w[name string_answer choice_answer number_answer]

  def self.field_names = %w[name survey_question survey_response string_answer choice_answer
                            number_answer]

  def name
    "Answer for #{survey_question.name}"
  end

end
