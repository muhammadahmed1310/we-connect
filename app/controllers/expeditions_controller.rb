class ExpeditionsController < WeHubController
  helper_method :can_edit?
  def index_action_menu
    return @index_action_menu if defined?(@index_action_menu)

    if @parent.is_a?(Organisation)
      @index_action_menu = [
        {
          label: 'Export to Excel',
          method: :post,
          url: bulk_action_expeditions_path,
          data: {
            controller: "bulk-action",
            action: "click->bulk-action#submitFromMenu",
            "bulk-action-action-value": "export_excel"
          }
        }
      ]
      return @index_action_menu
    end

    menu = [
      {
        label: 'Create Group Expedition',
        id: 'create_group_expedition',
        partial: 'new_from_skeleton',
        locals: { expedition_type: 'group' }
      },
      {
        label: 'Create Solo Expedition',
        id: 'create_solo_expedition',
        partial: 'new_from_skeleton',
        locals: { expedition_type: 'solo' }
      },
      {
        label: 'Batch Expeditions Upload',
        id: 'batch_expedition_upload',
        partial: 'batch_expedition_upload'
      }
    ]

    @bulk_actions ||= index_bulk_actions_for(Expedition).map do |label, action|
      {
        label: label,
        url: bulk_action_path,  # ← let WeHubController choose the correct bulk_action_*_path
        data: {
          controller: "bulk-action",
          action: "click->bulk-action#submitFromMenu",
          "bulk-action-action-value": action,
          turbo_method: :post      # ← match Users config
        }
      }
    end

    @index_action_menu = menu + @bulk_actions
  end


  def index_default_params = {is_skeleton: false}

  def index_add_button? = false

  def form_action_menu
    {}
  end

  def update
    new_leader_ids = Array(params[:expedition][:expedition_leader_ids]).reject(&:blank?).map(&:to_i)
    new_manager_ids = Array(params[:expedition][:community_manager_ids]).reject(&:blank?).map(&:to_i)
    new_partner_ids = Array(params[:expedition][:partner_organisation_ids]).reject(&:blank?).map(&:to_i)

    super do |success|
      next unless success

      # Sync leaders
      @item.expedition_users.where(expedition_role_type: 'leader').where.not(user_id: new_leader_ids).destroy_all
      new_leader_ids.each do |uid|
        @item.expedition_users.find_or_create_by(user_id: uid, expedition_role_type: 'leader')
      end

      # Sync managers
      @item.expedition_users.where(expedition_role_type: 'manager').where.not(user_id: new_manager_ids).destroy_all
      new_manager_ids.each do |uid|
        @item.expedition_users.find_or_create_by(user_id: uid, expedition_role_type: 'manager')
      end

      # --- Sync Partners ---
      @item.expedition_organisations.where(expedition_organisation_type: 'partner').where.not(organisation_id: new_partner_ids).destroy_all
      new_partner_ids.each do |oid|
        @item.expedition_organisations.find_or_create_by(organisation_id: oid, expedition_organisation_type: 'partner')
      end
    end
  end

  def destroy
    unless current_user.admin?
      redirect_to expeditions_path, alert: "Only admins can delete expeditions." and return
    end
    super
  end

  def tasks
    @expedition = Expedition.find(params[:id])
    @phases = @expedition.expedition_phases.includes(:tasks)

    @task_bulk_actions = index_bulk_actions_for(Activity).map do |label, action|
      {
        label: label,
        method: :post,
        url: main_app.bulk_action_expedition_activities_path(@expedition),
        data: {
          controller: 'bulk-action',
          action: 'click->bulk-action#submitFromMenu',
          "bulk-action-action-value": action
        }
      }
    end
  end

  def create_from_skeleton
    skeleton = Expedition.find(params[:skeleton_expedition_id])
    expedition = Expedition.create_from_skeleton(
      params[:expedition_name],
      skeleton.start_date,
      skeleton.end_date,
      skeleton,
      {},
      current_user
    )


    redirect_to expedition_path(expedition)
  end


  def batch_upload
    if params[:file].nil?
      flash[:error] = "Please upload the expedition sheet"
      redirect_to expeditions_path and return
    end

    service = ExcelUploadService.new(params[:file], Expedition, ExpeditionParsing, current_user: current_user)
    result = service.call

    if result.is_a?(Hash) && result[:success]
      redirect_to expeditions_url, notice: "Expeditions uploaded successfully."
    else
      flash[:alert] = result[:message] # 🔴 use :alert so it shows
      redirect_to expeditions_path and return
    end
  end
  def expedition_params
    params.require(:expedition).permit(:name, :expedition_type, :start_date, :end_date,
                                       :description,community_manager_ids: [], expedition_leader_ids: [],
                                       partner_organisation_ids: [])
  end

  def can_edit?(item = nil)
    expedition = item || @item
    return false unless expedition

    current_user.staff? || current_user.community_manager_of?(expedition)
  end


end
