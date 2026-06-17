# frozen_string_literal: true

module ApplicationHelper
  include PathHelper

  def version_number
    @version_number ||= begin
      v = File.read('VERSION').strip
      b = File.read('BUILD_NUMBER').strip
      "#{v}-#{b}"
    end
  end

  def bulk_action_route_defined?
    Rails.application.routes.named_routes.helper_names.include?("bulk_action_#{controller_name}_path")
  end
  def camel_label(val)
    val.to_s.tr('_', ' ').squeeze(' ').strip.titleize
  end

end
