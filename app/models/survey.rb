# The Survey defines a specific survey that can be taken by users.
#
# A survey is a collection of survey pages, which can each contain survey questions but
# are not required to. The pages are styled as HTML with the question placeholders embedded.
#
# Survey responses are the answers to the survey questions, and are associated with a user.
#
# A survey can be associated with one or more expeditions and activities.
class Survey < ApplicationRecord
  has_paper_trail

  belongs_to :author, class_name: 'User'
  has_many :survey_pages, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_many :survey_questions, through: :survey_pages

  has_many :survey_expeditions, dependent: :destroy
  has_many :expeditions, through: :survey_expeditions

  has_many :survey_activities, dependent: :destroy
  has_many :activities, through: :survey_activities

  def self.sub_records = %w[survey_pages survey_responses survey_questions]

  def self.table_names = %w[name survey_type survey_pages]

  def self.field_names = %w[name survey_type survey_status_type version author notes]
end
