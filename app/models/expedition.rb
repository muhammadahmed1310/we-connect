class Expedition < ApplicationRecord
  include Scopable
  include ExpeditionParsing
  before_save :calculate_progress

  attr_accessor :partner_organisation_ids

  before_save :sync_partner_organisations


  has_many :expedition_phases, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :expedition_contents, dependent: :destroy
  has_many :expedition_organisations, dependent: :destroy
  has_many :expedition_users, dependent: :destroy
  has_many :survey_expeditions, dependent: :destroy

  has_many :contents, through: :expedition_contents
  has_many :organisations, through: :expedition_organisations
  has_many :users, through: :expedition_users
  has_many :surveys, through: :survey_expeditions


  has_many :tasks, -> { where(activities: {activity_type_id: Choice.task_type_id}) },
           class_name: 'Activity', dependent: :nullify
  has_many :meetings, -> { where(activities: {activity_type_id: Choice.meeting_type_id}) },
           class_name: 'Activity', dependent: :nullify
  has_many :explorers, -> { where(expedition_users: {expedition_role_type: 'explorer'}) },
           through: :expedition_users,
           source: :user
  has_many :partner_organisations, -> { where(expedition_organisations: {expedition_organisation_type: 'partner'}) },
           through: :expedition_organisations,
           source: :organisation

  has_many :community_managers, -> { where(expedition_users: {expedition_role_type: 'manager'}) },
           through: :expedition_users,
           source: :user

  has_many :expedition_leaders, -> { where(expedition_users: {expedition_role_type: 'leader'}) },
           through: :expedition_users,
           source: :user

  # Validations
  validates :expedition_type, presence: true
  validates :expedition_phase_type, presence: true
  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  # Scopes for tables
  we_scopes :expedition_type

  # Nested collections
  accepts_nested_attributes_for :activities, allow_destroy: true

  def self.sub_records = %w[tasks meetings expedition_users expedition_organisations
                            expedition_phases]

  def self.table_names = %w[name expedition_type expedition_phase_type start_date end_date]

  def self.field_names = %w[name expedition_type start_date end_date expedition_phase_type
                            funded_amount location
                            is_platform_created is_marketing_completed
                            is_ip_agreement_signed is_impact_survey_completed
                            is_member_agreement_completed is_active
                            description ]


  def self.create_from_skeleton(name, start_date, end_date, skeleton, attributes = {}, user = nil)
    e = Expedition.new(
      name: name,
      expedition_type: skeleton.expedition_type,
      expedition_phase_type: skeleton.expedition_phase_type,
      start_date: start_date,
      end_date: end_date
    )
    attributes.each { |k, v| e[k] = v if e.respond_to?(k) }
    if e.save
      PaperTrail::Version.create!(
        item_type: 'Expedition',
        item_id: e.id,
        event: 'create',
        object: e.attributes.to_json,
        whodunnit: user&.id # <-- use passed-in user here
      )
    end
    # Map old -> new phases by name
    phase_map = {}
    skeleton.expedition_phases.each do |phase|
      new_phase = e.expedition_phases.create!(name: phase.name)
      phase_map[phase.name] = new_phase
    end

    # Prepare bulk insert for activities
    bulk_activities = skeleton.activities.map do |a|
      {
        name: a.name,

        activity_type_id: a.activity_type_id,
        activity_status_type_id: a.activity_status_type_id,
        expedition_id: e.id,
        expedition_phase_id: phase_map[a.expedition_phase.name].id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    Activity.insert_all(bulk_activities)

    e
  end

  def explorer?(user)
    explorers.include?(user)
  end

  def user_roles(user)
    expedition_users.where(user: user).collect(&:expedition_role_type)
  end

  def community_manager_ids
    community_managers.pluck(:id)
  end

  def expedition_leader_ids
    expedition_leaders.pluck(:id)
  end

  def can_edit?(user)
    user.staff? 
  end

  def can_view?(user)
    user.staff? || explorer?(user)
  end

  def calculate_progress
    self.progress = calculate_progress!
  end

  def calculate_progress!
    total_tasks = tasks.count
    return 0 if total_tasks.zero?

    completed_tasks = tasks.where(is_completed: true).count
    ((completed_tasks.to_f / total_tasks) * 100).round
  end

  # app/models/expedition.rb
  def sync_expedition_roles!(leader_ids:, manager_ids:)
    # Clean up old roles not in new list
    expedition_users.where(expedition_role_type: 'leader').where.not(user_id: leader_ids).destroy_all
    expedition_users.where(expedition_role_type: 'manager').where.not(user_id: manager_ids).destroy_all

    # Add new or existing users
    leader_ids.reject(&:blank?).each do |uid|
      expedition_users.find_or_create_by(user_id: uid, expedition_role_type: 'leader')
    end

    manager_ids.reject(&:blank?).each do |uid|
      expedition_users.find_or_create_by(user_id: uid, expedition_role_type: 'manager')
    end
  end


  def sync_partner_organisations
    return unless partner_organisation_ids

    # Remove old ones not in the new selection
    expedition_organisations.where(expedition_organisation_type: 'partner')
                            .where.not(organisation_id: partner_organisation_ids.reject(&:blank?))
                            .destroy_all

    # Add new ones
    partner_organisation_ids.reject(&:blank?).each do |org_id|
      expedition_organisations.find_or_create_by(
        organisation_id: org_id,
        expedition_organisation_type: 'partner'
      )
    end
  end



end
