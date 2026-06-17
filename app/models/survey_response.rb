# A response by a given user to a survey.
#
class SurveyResponse < ApplicationRecord
  has_paper_trail

  belongs_to :survey
  belongs_to :user
  belongs_to :expedition, optional: true
  belongs_to :activity, optional: true
  belongs_to :last_viewed_page, class_name: 'SurveyPage', optional: true
  has_many :survey_answers, dependent: :destroy

  def self.sub_records = %w[survey_answers]

  def self.table_names = %w[name]

  def self.field_names = %w[name survey user expedition activity started_at survey_response_status_type
                            last_viewed_page]

  def name = "Response to #{survey.name} by user #{user.name}"

end
