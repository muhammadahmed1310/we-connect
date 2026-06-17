class ExpeditionUsersController < WeHubController
  helper_method :can_edit?
  def create_redirect_path = expedition_expedition_users_path(@item.expedition)

  def join_table? = true

  def index_action_menu
    @bulk_actions ||= index_bulk_actions_for(ExpeditionUser).map do |label, action|
      {
        label: label,
        method: :post,
        url: bulk_action_path,
        data: {
          controller: 'bulk-action',
          action: 'click->bulk-action#submitFromMenu',
          "bulk-action-action-value": action
        }
      }
    end
  end

  def create
    @item = ExpeditionUser.new(expedition_user_params)

    if @item.save
      # HTML (full reload) – keeps your current non-dimming behavior
      redirect_to expedition_expedition_users_path(@item.expedition),
                  notice: "Added 1 user to the expedition."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def change_role
    expedition_id = params[:expedition_id]
    role_id = params[:role_choice_item_id]
    selected_ids = Array(params[:selected_ids]).reject(&:blank?)

    role_item = ChoiceItem.find_by(id: role_id)
    role = role_item&.name

    puts "🧠 Role ID: #{role_id}, Role: #{role}"
    puts "👥 Selected ExpeditionUser IDs: #{selected_ids.inspect}"

    if role.blank?
      redirect_to expedition_users_path(expedition_id), alert: 'Invalid role.' and return
    end

    if selected_ids.empty?
      redirect_to expedition_users_path(expedition_id), alert: 'No users selected.' and return
    end

    expedition_users = ExpeditionUser.includes(:user, :expedition).where(id: selected_ids)

    old_roles = expedition_users.index_by(&:id).transform_values { |eu| eu.expedition_role_type || '—' }

    expedition_users.find_each do |exp_user|
      puts "🔁 Updating ExpeditionUser #{exp_user.id} → role: #{role}"
      exp_user.update!(expedition_role_type: role)
    end

    updated = ExpeditionUser.includes(:user, :expedition).where(id: selected_ids)
    new_roles = updated.index_by(&:id).transform_values { |eu| eu.expedition_role_type || '—' }

    records = selected_ids.map do |id|
      eu = updated.find { |e| e.id == id.to_i }
      {
        id: id,
        name: eu&.user&.name || 'Unknown',
        type: 'User',
        expedition_id: eu&.expedition_id,
        expedition_name: eu&.expedition&.name,
        from: Array.wrap(old_roles[id.to_i]).reject(&:blank?),
        to: Array.wrap(new_roles[id.to_i]).reject(&:blank?)
      }
    end

    PaperTrail::Version.create!(
      item_type: 'ExpeditionUser',
      item_id: selected_ids.first,
      event: 'bulk_change_role',
      object: {
        action: 'change_role',
        expedition_id: expedition_id,
        expedition_name: Expedition.find_by(id: expedition_id)&.name,
        records: records
      }.to_json,
      whodunnit: current_user.id
    )

    redirect_to request.referer || expedition_users_path(expedition_id), notice: 'Roles updated.'
  end

  def can_edit?(item = nil)
    activity = item || @item
    expedition = activity&.expedition || @parent # depending on how parent is set
    return false unless expedition

    current_user.staff? || current_user.community_manager_of?(expedition)
  end

  private
  def expedition_user_params
    params.require(:expedition_user).permit(:expedition_id, :user_id, :expedition_role_type)
  end
end
