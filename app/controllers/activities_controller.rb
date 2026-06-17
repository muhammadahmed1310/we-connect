class ActivitiesController < WeHubController
  helper_method :can_edit?
  def bulk_action_path
    return bulk_action_expedition_activities_path(@parent) if @parent.is_a?(Expedition)
    super
  end
  def index_action_menu
    return @index_action_menu if defined?(@index_action_menu)

    @index_action_menu = index_bulk_actions_for(Activity).map do |label, action|
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

  def can_edit?(item = nil)
    activity = item || @item
    expedition = activity&.expedition || @parent # depending on how parent is set
    return false unless expedition

    current_user.staff? || current_user.community_manager_of?(expedition)
  end

  private

  def item_params
    permitted = params.fetch(:activity, {}).permit!

    if permitted[:activity_status_type_id].present? && permitted[:activity_status_type_id] !~ /\A\d+\z/
      permitted[:activity_status_type_id] =
        ChoiceItem.find_by(name: permitted[:activity_status_type_id])&.id
    end

    if permitted[:activity_type_id].present? && permitted[:activity_type_id] !~ /\A\d+\z/
      permitted[:activity_type_id] =
        ChoiceItem.find_by(name: permitted[:activity_type_id])&.id
    end

    permitted
  end
end
