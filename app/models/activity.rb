class Activity < ApplicationRecord

  belongs_to :expedition, optional: true
  belongs_to :expedition_phase, optional: true
  belongs_to :location, optional: true
  belongs_to :assigned_user, class_name: 'User', optional: true

  has_many :activity_contents, dependent: :destroy
  has_many :expedition_contents

  has_many :contents, through: :activity_contents
  has_many :expeditions, through: :expedition_contents

  acts_as_list scope: :expedition


  belongs_to :activity_type, class_name: 'ChoiceItem', optional: true
  belongs_to :activity_status_type, class_name: 'ChoiceItem', optional: true
  after_commit :notify_assigned_user, on: [:create, :update]
  def activity_type_name
    activity_type&.name
  end

  def activity_status_name
    activity_status_type&.name
  end

  def self.sub_records = %w[activity_contents]

  def self.table_names = %w[name activity_type activity_status_type assigned_user
                            start_date deadline_date is_completed]

  def self.field_names = %w[name activity_type activity_status_type assigned_user
                            start_date deadline_date location description notes position
                            is_completed]

  private


  def notify_assigned_user(assigner = nil)
    return unless saved_change_to_assigned_user_id? && assigned_user.present?

    NotificationMailer.task_assigned(assigned_user, self, assigner).deliver_later
  end


end
