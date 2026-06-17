class ExpeditionPhase < ApplicationRecord

  belongs_to :expedition
  has_many :activities, dependent: :nullify
  has_many :tasks,
           -> {
             joins("INNER JOIN choice_items ON choice_items.id = activities.activity_type_id")
               .where("choice_items.name = 'task'")
           },
           class_name: 'Activity',
           dependent: :nullify

  has_many :meetings,
           -> {
             joins("INNER JOIN choice_items ON choice_items.id = activities.activity_type_id")
               .where("choice_items.name = 'meeting'")
           },
           class_name: 'Activity',
           dependent: :nullify


  validates :name, presence: true

  def self.sub_records = %w[]

  def self.table_names = %w[name start_date end_date is_completed]

  def self.field_names = %w[name start_date end_date is_completed]
end
