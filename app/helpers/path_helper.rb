# Adds some generic helpers for generating paths for items
module PathHelper

  # Path for the list of items for the current controller taking global parent into account
  def items_path(options = {})
    path_parts = @parent ? [@parent, controller_name.to_sym] : [controller_name.to_sym]
    url_for(path_parts + [{ params: options }])
  rescue ActionController::UrlGenerationError
    "/#{controller_name}?#{options.to_query}"
  end


  def edit_item_path(item)
    url_for([:edit, item])
  end

  # New item path for the current controller
  def new_item_path
    if @parent
      url_for([:new, @parent, controller_name.singularize.to_sym])
    else
      url_for([:new, controller_name.singularize.to_sym])
    end
  end

  # Path for the list of versions for a papertrail item
  def versions_path(item)
    "/#{item.model_name.route_key}/#{item.id}/versions"
  end

  def sort_direction(column)
    params[:sort] == column && params[:direction] == 'asc' ? 'desc' : 'asc'
  end


  # Path for a specific version of a papertrail item
  def version_path(item, version)
    "/#{item.model_name.route_key}/#{item.id}?version=#{version.id}"
  end


  def parent_through_association?
    assoc_name = @parent.class.to_s.downcase.pluralize.to_sym
    r = controller.model.reflect_on_association(assoc_name)
    r&.through_reflection?
  end

end
