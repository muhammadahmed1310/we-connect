module TableHelper

  # Scopes for the current model
  def display_scopes
    if controller.model.respond_to?(:_scopes_hash)
      controller.model._scopes_hash
    else
      {}
    end
  end

  def scope_link(scope, filter_label, filter_value)
    link_text = filter_label.to_s
    link_text = '[blank]' if link_text.blank?
    link_to link_text,
            items_path(scope => filter_value || link_text, search: params[:search]),
            class: "nav-link #{params[:scope] == scope ? 'active' : ''}"
  end

  def scope_name(scope)
    return "#{scope.to_s.gsub('is_', '')}?".titleize if scope.start_with? 'is_'
    scope.to_s.gsub('_id', '').titleize
  end



end
