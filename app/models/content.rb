# Content can be any type of content, including html, pdf files, images, videos, etc.
#
# It can also be used as html templates for webpages and emails and be associated with
# expeditions and activities.
#
class Content < ApplicationRecord
  has_paper_trail
  belongs_to :author, class_name: 'User'

  has_many :expedition_contents, dependent: :destroy
  has_many :activity_contents, dependent: :destroy

  has_many :expeditions, through: :expedition_contents
  has_many :activities, through: :activity_contents, class_name: 'Activity'

  def self.sub_records = %w[]

  def self.table_names = %w[name author activity_contents expedition_contents]

  def self.field_names = %w[name author description content_type is_active is_published
                            is_sent content]

end
