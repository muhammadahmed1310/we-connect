# frozen_string_literal: true

# Sends the request to the controller to check if the user can edit the item or
# this type of item if the specific item is nil
module PermissionHelper
  def can_edit?(item = nil)
    controller&.can_edit?(item)
  end

  def can_view?(item)
    controller&.can_view?(item)
  end
end
