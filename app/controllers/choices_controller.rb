class ChoicesController < WeHubController

  # only staff can view and edit
  def can_edit?(_item = nil)
    current_user.staff?
  end

  def can_view?(_item = nil)
    current_user.staff?
  end



  def index_action_menu
    return @index_action_menu if defined?(@index_action_menu)

    @index_action_menu = index_bulk_actions_for(Choice).map do |label, action|
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
    @index_action_menu = index_action_menu.flatten
  end

end
