class BulkVersionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @version = PaperTrail::Version.find(params[:id])
    @action_type = @version.event
    parsed_data = JSON.parse(@version.object || '{}') rescue {}
    records = parsed_data['records'] || parsed_data['users']

    # If no `records` key, build a record from changeset for single updates
    if records.blank? && @version.changeset.present?
      changeset = @version.changeset

      record = {
        'id' => @version.item_id,
        'name' => @version.item.try(:name) || @version.item_type,
        'type' => @version.item_type,
        'from' => changeset.transform_values(&:first),
        'to'   => changeset.transform_values(&:last)
      }

      records = [record]
    end

    # Default to empty array if still nil
    records ||= []

    # Paginate manually using will_paginate’s array pagination
    @paginated_changes = WillPaginate::Collection.create(
      params[:page] || 1, 50, records.length
    ) do |pager|
      start = (pager.current_page - 1) * pager.per_page
      pager.replace(records[start, pager.per_page] || [])
    end
  end
end
