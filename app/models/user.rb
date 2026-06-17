# All users who log into the system


require 'countries'
class User < ApplicationRecord
  include PaperTrailCustom
  has_paper_trail on: [:create, :update, :destroy],
                  ignore: [:sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]

  include Searchable
  searchable_columns :email, :first_name, :last_name, :country

  # Virtual: FULL NAME (first_name + ' ' + last_name) — adapter-agnostic via CONCAT_WS
  searchable_virtual :full_name do |t|
    Arel::Nodes::NamedFunction.new(
      'CONCAT_WS',
      [Arel::Nodes.build_quoted(' '), t[:first_name], t[:last_name]]
    )
  end

  # If you want role name text to match too:
  searchable_association :user_role_types, :name
  def paper_trail_attributes_for_destroy
    { name: self.name }
  end
  before_validation :assign_default_owner, on: :create
  after_commit :apply_guide_defaults_if_needed!, on: :create

  before_create :set_default_role
  include Scopable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :first_name, presence: true

  validates :email,
            presence: true,
            uniqueness: true,
            format: {with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/i}

  validates :password,
            presence: true,
            length: Devise.password_length,
            unless: :is_contact_only?,
            if: :password_required?

  validates :password_confirmation,
            presence: true,
            unless: :is_contact_only?,
            if: :password_required?

  # single, clear predicate
  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end

  has_many :expedition_users, dependent: :destroy
  has_many :activities, foreign_key: 'assigned_user_id', dependent: :nullify
  has_many :contents, foreign_key: 'author_id', dependent: :nullify
  has_many :locations
  has_many :expeditions, through: :expedition_users
  has_many :organisation_users, dependent: :destroy
  has_many :organisations, through: :organisation_users
  belongs_to :owner, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true


  validates :owner, presence: true, if: :contact?

  validate :owner_required_for_contacts
  validate :owner_edit_protection
  validates :nationality, inclusion: {in: ISO3166::Country.all.map(&:iso_short_name), allow_nil: true}, presence: true,
                          unless: :is_contact_only?

  validates :country, inclusion: {in: ISO3166::Country.all.map(&:iso_short_name), allow_nil: true}, presence: true,
                      unless: :is_contact_only?

  we_scopes :is_active
  has_many :user_role_choice_items, dependent: :destroy
  has_many :user_role_types, through: :user_role_choice_items, source: :choice_item

  accepts_nested_attributes_for :user_role_choice_items, allow_destroy: true
  validate :password_required_unless_contact_only

  validate :password_required_when_switching_from_contact_to_user

  def password_required_when_switching_from_contact_to_user
    return unless will_save_change_to_is_contact_only?

    from, to = is_contact_only_change_to_be_saved
    return unless from == true && to == false  # contact -> user

    if password.blank? || password_confirmation.blank?
      errors.add(:password, "can't be blank")
      errors.add(:password_confirmation, "can't be blank")
    elsif password != password_confirmation
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end

  def user_role_type_labels
    user_role_types.map { |r| r.name.to_s.tr('_',' ').titleize }.join(', ')
  end

  def user_role_type_names
    user_role_types.map { |r| r.name.to_s.tr('_',' ').titleize }.join(', ')
  end


  def user_role_type_ids=(ids)
    self.user_role_types = ChoiceItem.where(id: ids.reject(&:blank?))
  end


  def user_role_type_ids
    user_role_types.pluck(:id)
  end

  def self.table_names = %w[name email user_role_types country contact_permission]

  def self.field_names = %w[first_name last_name email password password_confirmation nationality country industry_type organisation
                            user_role_type_ids job_title phone secondary_email linkedin_url notes created_by is_contact_only]

  def self.sub_records = %w[]

  def name = "#{first_name} #{last_name}"

  def full_name
    [first_name, last_name].compact.join(' ')
  end

  # Is the user an overall admin?
  def admin?
    user_role_types.any? { |r|  r.name.to_s.downcase == 'administrator' }
  end

  def staff? = user_role_types.any? { |r| %w[administrator staff].include?(r.name.to_s.downcase ) }
  def guide?
    user_role_types.any? { |r| r.name.to_s.downcase == 'guide' }
  end
  def community_manager_of?(expedition)
    return false unless expedition.present?
    expedition_users.exists?(
      expedition_id: expedition.id,
      expedition_role_type: 'community_manager' # uses your string column
    )
  end

  scope :staff_or_admin, -> {
    joins(:user_role_types).where(choice_items: { name: %w[administrator staff] }).distinct
  }


  def set_default_role
    self.organisation_user_role_type ||= 'member'
  end

  def self.search_fields = %w[first_name last_name email country]

  def active_for_authentication?
    super && !is_contact_only?
  end

  def inactive_message
    is_contact_only? ? :contact_only : super
  end

  def closed_to_outreach?
    is_contact_restricted
  end

  def contact?
    is_contact_only?
  end

  def login_user?
    !is_contact_only?
  end

  # Convenience for permission column (unchanged if you already have it)
  def closed_to_outreach?
    self.is_contact_restricted == true
  end

  # who can edit owner/closed flags
  def can_change_owner?(actor) = actor&.admin? || owner_id == actor&.id
  def can_change_closed_flag?(actor) = can_change_owner?(actor)

  def password_required_unless_contact_only
    if !is_contact_only && (new_record? || password.present? || password_confirmation.present?)
      if password.blank? || password_confirmation.blank?
        errors.add(:password, "can't be blank")
      end
    end
  end

  private

  # --- Password rules ---
  def password_presence_on_create_for_login
    return if contact?
    return unless new_record?

    if password.blank? || password_confirmation.blank?
      errors.add(:password, "can't be blank")
      errors.add(:password_confirmation, "can't be blank")
    end
  end
  def assign_default_owner
    return if owner_id.present?
    self.owner_id = created_by_id if created_by_id.present?
  end
  def owner_required_for_contacts
    return unless contact?
    errors.add(:owner, "must be assigned") if owner.blank?
  end


  # Apply default owner + closed permission for Guides only.
  # - Set owner to Funmi if no owner yet.
  # - Close to outreach by default (don’t overwrite if someone already set it).
  def apply_guide_defaults_if_needed!
    return unless guide?

    funmi = User.find_by(email: 'funmi.adeyemi@womenemerging.org')
    changed_any = false

    if funmi && owner_id != funmi.id
      self.owner_id = funmi.id
      changed_any = true
    end

    # Default closed, but don't force if already manually set true/false
    if is_contact_restricted.nil?
      self.is_contact_restricted = true
      changed_any = true
    end

    save! if changed_any
  end
  def owner_edit_protection
    return unless will_save_change_to_owner_id?

    # Allow programmatic switch to Funmi
    funmi_id = User.find_by(email: 'funmi.adeyemi@womenemerging.org')&.id
    return if funmi_id.present? && owner_id == funmi_id

    if login_user? && !PaperTrail.request.whodunnit.blank?
      editor = User.find_by(id: PaperTrail.request.whodunnit)
      unless editor&.admin?
        errors.add(:owner_id, "can only be changed by an administrator for staff accounts")
      end
    end
  end

end
