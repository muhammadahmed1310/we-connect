class OrganisationsController < WeHubController
  before_action :authenticate_user!
  helper_method :can_edit?
  def index_action_menu
    return @index_action_menu if defined?(@index_action_menu)

    menu = [
      { label: 'Create New Organisation', id: 'add_organisation', partial: 'organisations/new_modal' }
    ]

    @bulk_actions ||= index_bulk_actions_for(Organisation).map do |label, action|
      {
        label: label,
        method: :post,
        url: bulk_action_organisations_path,
        data: {
          controller: 'bulk-action',
          action: 'click->bulk-action#submitFromMenu',
          'bulk-action-action-value': action
        }
      }
    end

    @index_action_menu = menu + @bulk_actions
  end

  def index_default_params = {}


  def can_edit?(_item = nil)
    current_user.staff?
  end

  def create
    name = params.dig(:organisation, :name).to_s.squish
    org_type = params.dig(:organisation, :organisation_type).presence
    if (existing = Organisation.where("LOWER(name) = ?", name.downcase).first)
      respond_to do |f|
        f.json { render json: { id: existing.id, name: existing.name, notice: "Organisation already exists. Selected it for you." }, status: :conflict }
        f.html { redirect_back fallback_location: users_path, alert: "Organisation already exists." }
      end
      return
    end

    org = Organisation.new(name: name, organisation_type: org_type)
    if org.save
      respond_to do |f|
        f.json { render json: { id: org.id, name: org.name, notice: "Organisation created." }, status: :created }
        f.html { redirect_back fallback_location: users_path, notice: "Organisation created." }
      end
    else
      respond_to do |f|
        f.json { render json: { errors: org.errors.full_messages }, status: :unprocessable_entity }
        f.html { redirect_back fallback_location: users_path, alert: org.errors.full_messages.join(", ") }
      end
    end
  end

  private
  def organisation_params
    params.require(:organisation).permit(:name, :organisation_type)
  end

end
