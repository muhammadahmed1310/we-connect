# frozen_string_literal: true

class WeHubController < ApplicationController
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_item, only: %i[show edit update destroy versions]
  before_action :authorize_delete, only: [:destroy, :bulk_action]
  # GET /<items> or /<items>.json
  # Options for all requests:
  # * a parent object can be passed in the url or in the params
  # * the default title for the table is the controller but can be overriden


  def index
    params.reverse_merge!(index_default_params)
    @title = if controller_name == 'users'
               'Contacts'
             else
               controller_name.titleize
             end
    # Parent attributes can be in the url
    parent_key = params.keys.detect { |k| k.ends_with?('_id') }

    if parent_key
      parent_model = parent_key.gsub('_id', '').classify.constantize
      @parent = parent_model.find_by(id: params[parent_key])

      if @parent
        assoc = model_name.pluralize.underscore
        query = @parent.respond_to?(assoc) ? @parent.send(assoc) : model.all
      else
        query = model.all
      end
    else
      query = model.all
    end

    puts "MODEL NAME: #{model.name}"
    @actions = index_bulk_actions_for(model)

    @index_action_menu = index_action_menu.flatten
    # Search logic if search param (q) is not empty
    unless params[:q].blank?
      if model.respond_to?(:apply_search)
        query = model.apply_search(query, params[:q])
      else
        # Fallback: search all string/text columns on the base table
        q = "%#{params[:q]}%"
        table     = model.arel_table
        text_cols = model.columns.select { |c| [:string, :text].include?(c.type) }.map(&:name)
        if text_cols.any?
          cond = text_cols.map { |c| table[c].matches(q) }.reduce { |acc, n| acc.or(n) }
          query = query.where(cond)
        end
      end
    end
    # Handle a filter parameter (for the moment, any parameter ending in _type)
    # filters = params.keys.select { |k| k.end_with?('_type') || k.start_with?('is_') }
    # filters.each do |filter|
    #   query = query.where(filter => params[filter])
    #   if filter.start_with?('is_')
    #     f = filter.gsub('is_', '').pluralize.titleize
    #     @title += params[filter] == '1' ? " - #{f}" : ''
    #   else
    #     @title += ": #{params[filter].pluralize.titleize}"
    #   end
    # end

    # Filter
    if model == User
      if params[:closed_only] == '1'
        query = query.where(is_contact_restricted: true)
      end
      if params[:user_role_type_ids].present?
        role_ids = Array(params[:user_role_type_ids]).reject(&:blank?).map(&:to_i)
        if role_ids.any?
          query = query.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: role_ids }).distinct
        end
      end

      query = query.where(country: Array(params[:country]).reject(&:blank?)).distinct if params[:country].present?
      industry_values = Array(params[:industry_type]).reject(&:blank?)
      if industry_values.any?
        query = query.where(industry_type: industry_values).distinct
      end

      if params[:created_at_from].present?
        query = query.where('users.created_at >= ?', params[:created_at_from])
      end
      if params[:created_at_to].present?
        query = query.where('users.created_at <= ?', params[:created_at_to])
      end
    elsif model == Expedition
      if params[:expedition_type].present?
        ids = params[:expedition_type].reject(&:blank?).map(&:to_i)
        expedition_type_names = ChoiceItem.where(id: ids).pluck(:name)
        query = query.where(expedition_type: expedition_type_names) if expedition_type_names.any?
      end

      if params[:expedition_phase_type].present?
        ids = params[:expedition_phase_type].reject(&:blank?).map(&:to_i)
        expedition_phase_type_names = ChoiceItem.where(id: ids).pluck(:name)
        query = query.where(expedition_phase_type: expedition_phase_type_names) if expedition_phase_type_names.any?
      end

      if params[:location].present?
        query = query.where('location LIKE ?', "%#{params[:location]}%")
      end
      query = query.where(is_skeleton: false) if model == Expedition
    elsif model == Organisation
      if params[:organisation_type].present?
        ids = params[:organisation_type].reject(&:blank?).map(&:to_i)
        names = ChoiceItem.where(id: ids).pluck(:name)
        query = query.where(organisation_type: names) if names.any?
      end

      if params[:created_at_from].present?
        query = query.where('organisations.created_at >= ?', params[:created_at_from])
      end
      if params[:created_at_to].present?
        query = query.where('organisations.created_at <= ?', params[:created_at_to])
      end
    elsif model == ExpeditionUser
    # by role name(s)
    if params[:expedition_role_type].present?
      role_names = Array(params[:expedition_role_type]).reject(&:blank?)
      query = query.where(expedition_role_type: role_names)
    end

    # by user name/email
    if params[:user_name].present?
      like = "%#{params[:user_name].strip}%"
      query = query.joins(:user)
                   .where("CONCAT(users.first_name, ' ', users.last_name) LIKE ? OR users.email LIKE ?", like, like)
    end
  end
    puts "FILTER VALUES: #{expedition_phase_type_names.inspect}"


    # Handle permission
    query = query.for_user_read(current_user) if model.respond_to?(:for_user)

    # Add any sort order
    query = apply_sorting(query)


    query = query.distinct
    puts "QUERY: #{query.all.to_sql}" unless Rails.env.production?
    @items = query.all

    @items = query.to_a

    pk = model.primary_key || 'id'
    @total_count = query.reselect("#{model.table_name}.#{pk}").distinct.count

    # ⬇️ Only paginate for HTML/JSON. For XLSX, export the full filtered set.
    if request.format.xlsx?
      @items = query.to_a
    else
      per_page = params[:per_page].presence || session[:per_page] || 25
      session[:per_page] = per_page
      @items = query.paginate(page: params[:page], per_page: per_page)
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render :index }
      format.xlsx
    end
  end


  # GET /<items>/1 or /<items>/1.json
  def show
    if params['version']
      @version = PaperTrail::Version.find_by(id: params['version'])
      @item = @version.reify
    end
    respond_to do |format|
      format.html { render :show }
      format.json { render :show }
    end
  end

  # GET /<items>/new
  def new
    detect_parent
    @item = model.new

    if @parent
      attributes = {@parent.class.to_s.downcase.to_sym => @parent}
      @item = model.new(item_params.merge(attributes))
    else
      @item = model.new(item_params)
    end
    respond_to do |format|
      format.html { render :edit }
      format.json { render :edit }
    end
  end

  # GET /<items>/1/edit
  def edit
    respond_to do |format|
      format.html { render :edit }
      format.json { render :edit }
    end
  end

  # POST /<items> or /<items>.json
  def create
    detect_parent

    attributes = {}

    attributes[@parent.class.to_s.downcase.to_sym] = @parent if @parent

    # Merge parent attributes with form parameters
    attributes.merge!(item_params)
    puts "Received params: #{item_params.inspect}"
    @item = model.new(attributes)
    if model == User
      @item.created_by ||= current_user

      incoming_role_ids = Array(item_params[:user_role_type_ids]).reject(&:blank?).map(&:to_i)
      is_guide = ChoiceItem.where(id: incoming_role_ids)
                           .where('LOWER(name) = ?', 'guide')
                           .exists?

      # Only default owner if:
      # - this is effectively a CONTACT (or you want that behaviour),
      # - no explicit owner was chosen,
      # - and it's not a new Guide.
      if @item.owner.nil? && !is_guide && @item.respond_to?(:contact?) && @item.contact?
        @item.owner = current_user
      end
    end

    puts "RAW params: #{params.inspect}"
    puts "item_params: #{item_params.inspect}"

    success = @item.save
    yield(success) if block_given?

    respond_to do |format|
      if @item.save
        format.html { redirect_to create_redirect_path, notice: 'Created' }
      else
        format.html { render :edit, status: :unprocessable_entity, alert: @item.errors.full_messages.join(', ') }
      end

    end
  end

  # PATCH/PUT /<items>/1 or /<items>/1.json
  # app/controllers/we_hub_controller.rb
  # app/controllers/we_hub_controller.rb
  # app/controllers/we_hub_controller.rb
  def update
    detect_parent

    success = @item.update(item_params)
    yield(success) if block_given?

    respond_to do |format|
      if success
        target = item_path                                 # ← go to SHOW after save
        format.turbo_stream { redirect_to target, status: :see_other, notice: 'Changes Saved' }
        format.html        { redirect_to target, status: :see_other, notice: 'Changes Saved' }
        format.json        { render :show, status: :ok, location: @item }
      else
        flash.now[:alert] = @item.errors.full_messages.to_sentence
        format.turbo_stream { render :edit, formats: :html, status: :unprocessable_entity }
        format.html        { render :edit, status: :unprocessable_entity }
        format.json        { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end





  # DELETE /<items>/1 or /<items>/1.json
  def destroy
    @item.destroy

    respond_to do |format|
      format.html do
        redirect_to helpers.items_path, notice: 'Removed'
      end
      format.json { head :no_content }
    end
  end

  # POST /<items>/reorder
  # To reorder items in a list with a position column
  def reorder
    the_model = model
    params[:id].each_with_index do |id, index|
      the_model.where(id: id).update(position: index + 1)
    end
    head :ok
  end

  def versions
    @versions = @item.versions
  end

  def version
    # @version = PaperTrail::Version.find_by_id(params[:version_id])
    # @item = @version.reify
  end

  # protected

  def model_name
    controller_path.singularize
  end

  def model
    model_name.classify.constantize
  end

  def table_fields
    helpers.table_fields_for(model)
  end

  # Sets the item (and possible parent) for the controller
  def set_item
    detect_parent
    @item = model.find(params[:id])
  end

  # Set the @parent object if it is present
  def detect_parent
    parent_key = params.keys.detect { |k| k.ends_with?('_id') && k != 'selected_ids' }

    # Fallback: extract parent ID from form payload if not in root params
    # In detect_parent
    if !parent_key && params[model_name.to_sym].is_a?(Hash)
      params[model_name.to_sym].each do |k, v|
        next unless k.ends_with?('_id')
        parent_key = k
        params[parent_key] ||= v # inject into root
        break
      end
    end

    return unless parent_key

    parent_model = parent_key.gsub('_id', '').classify.constantize
    @parent = parent_model.find_by(id: params[parent_key])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.fetch(model_name.to_sym, {}).permit!
  end

  def render_403
    render :render_403, status: :forbidden
  end

  def render_404
    render :render_404, status: :not_found
  end

  def edit_item_path
    helpers.edit_item_path(@item)
  end

  helper_method :item_path

  def item_path
    if join_table? && @parent
      parent_name = @parent.model_name.singular
      return public_send("#{parent_name}_#{controller_name}_path", @parent)
    end

    public_send("#{controller_name.singularize}_path", @item)
  end

  def new_item_path
    if @parent
      parent_name = @parent.model_name.singular
      helpers.public_send("new_#{parent_name}_#{controller_name.singularize}_path", @parent)
    elsif model.reflect_on_all_associations(:belongs_to).any?
      # fallback if parent is not detected but belongs_to exists
      assoc = model.reflect_on_all_associations(:belongs_to).find { |a| a.klass.name != 'User' }
      if assoc
        route = "new_#{assoc.name}_#{controller_name.singularize}_path"
        return helpers.public_send(route, assoc.klass.first) if helpers.respond_to?(route)
      end
      # If we can't find a suitable association, fall back to the simple route
      helpers.public_send("new_#{controller_name.singularize}_path")
    else
      helpers.public_send("new_#{controller_name.singularize}_path")
    end
  end

  def items_path
    detect_parent
    if @parent
      parent_name = @parent.model_name.singular
      helpers.public_send("#{parent_name}_#{controller_name}_path", @parent)
    else
      helpers.public_send("#{controller_name}_path")
    end
  end

  def bulk_action
    detect_parent
    @selected_ids = Array(params[:selected_ids]).reject(&:blank?)
    action = params[:bulk_action]
    puts "selected_ids: #{@selected_ids}"
    puts "action: #{action}"

    needs_selection = !%w[add export_excel add_to_organisation add_to_organisation_confirm].include?(action)

    if needs_selection && @selected_ids.blank?
      redirect_to items_path, alert: 'Please select at least one user' and return
    end


    respond_to do |format|
      case action
      when 'delete'
        records = []
        if model == User
          users = model.where(id: @selected_ids)
          # Skip users linked to expeditions as community manager or leader
          manager_role_ids = ChoiceItem.where(name: %w[community_manager expedition_leader]).pluck(:id)

          blocked_ids = ExpeditionUser
                        .where(user_id: @selected_ids, expedition_role_type_id: manager_role_ids)
                        .pluck(:user_id)
                        .uniq

          deletable = users.reject { |u| blocked_ids.include?(u.id) }
          undeletable = users.select { |u| blocked_ids.include?(u.id) }

          deleted_count = 0
          ActiveRecord::Base.transaction do
            deletable.each do |user|
              user.destroy!
              deleted_count += 1
              records << { id: user.id, name: user.name, type: user.class.name }
            end
          end

          if undeletable.any?
            names = undeletable.map(&:name).join(', ')
            flash[:alert] = "#{deleted_count} user(s) deleted. The following user(s) couldn't be deleted because they are assigned as a community manager or expedition leader: #{names}."
          else
            flash[:notice] = "#{deleted_count} user(s) deleted successfully."
          end
        else
          records = model.where(id: @selected_ids).map do |item|
            { id: item.id, name: item.try(:name) || item.to_s, type: item.class.name }
          end

          model.where(id: @selected_ids).destroy_all
          flash[:notice] = "#{records.size} records deleted."

          if records.any?
            PaperTrail::Version.create!(
              item_type: model.name,
              item_id: records.first[:id],
              event: 'bulk_delete',
              object: {
                action: 'delete',
                records: records
              }.to_json,
              whodunnit: current_user.id
            )
          end
        end
        @parent.update(progress: @parent.calculate_progress!) if @parent.is_a?(Expedition)

        format.html do
          target_path =
            if @parent.is_a?(Expedition) && request.referer&.include?('/tasks')
              tasks_expedition_path(@parent)
            else
              items_path
            end
          redirect_to target_path
        end
      when 'complete'
        records = []
        records = model.where(id: @selected_ids).map do |item|
          { id: item.id, name: item.try(:name) || item.to_s, type: item.class.name }
        end
        Activity.where(id: @selected_ids).update_all(is_completed: true)
        expedition_id = params[:expedition_id]
        expedition_name = Expedition.find_by(id: expedition_id)&.name
        @parent.update(progress: @parent.calculate_progress!) if @parent.is_a?(Expedition)

        PaperTrail::Version.create!(
          item_type: 'Activity',
          item_id: @selected_ids.first,
          event: 'bulk_complete',
          object: {
            action: 'complete',
            ids: @selected_ids,
            expedition_name: expedition_name,
            expedition_id: expedition_id,
            records: records
          }.to_json,
          whodunnit: current_user.id
        )
        flash[:notice] = "Marked #{@selected_ids.size} tasks as completed."
        format.html { redirect_back fallback_location: request.referer }

      when 'change_role'
        @is_expedition_context = @parent.is_a?(Expedition)
        @selected_users = User.where(id: @selected_ids)
        puts "selected_ids: #{@selected_ids}"
        puts "is_expedition_context: #{@is_expedition_context}"
        render partial: 'users/change_role_modal', locals: {
          selected_ids: @selected_ids.join(','),
          parent: @parent,
          selected_users: @selected_users
        }
      when 'export_excel'
        filters = Rack::Utils.parse_nested_query(params[:filters].to_s).reject { |_, v| v.blank? }
        export_url = polymorphic_url(
          @parent ? [@parent, model] : model,
          format: :xlsx,
          params: filters
        )


        exported = model.where(id: @selected_ids).map do |r|
          {
            id: r.id,
            name: r.try(:name) || r.to_s,
            type: r.class.name
          }
        end

        PaperTrail::Version.create!(
          item_type: model.name,
          item_id: exported.first&.[](:id) || 0,
          event: 'bulk_export',
          object: {
            action: 'export',
            records: exported,
            note: exported.any? ? nil : 'No items selected'
          }.to_json,
          whodunnit: current_user.id
        )
        format.html { redirect_to export_url }
      when 'add' #*****************
        format.html { redirect_to new_item_path }
      when 'add_to_expedition_confirm'
        expedition_id = params[:expedition_id]
        role = params[:expedition_role_type]

        # ids may come as comma string or multi-select array
        ids_param = params[:selected_ids]
        ids = Array(ids_param).flat_map { |x| x.to_s.split(',') }.reject(&:blank?).map(&:to_i)

        if expedition_id.blank?
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', '') }
            format.html { redirect_to items_path, alert: 'Please choose an expedition.' }
          end
          next
        end

        if role.blank?
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', '') }
            format.html { redirect_to items_path, alert: 'Please choose a role.' }
          end
          next
        end

        if ids.blank?
          respond_to do |format|
            format.turbo_stream do
              flash.now[:alert] = 'Please choose at least one user.'
              render turbo_stream: [
                turbo_stream.replace('layout-flash', partial: 'shared/layout_flash')
              ]
            end
            format.html { redirect_to items_path, alert: 'Please choose at least one user.' }
          end
          next
        end

        expedition = Expedition.find_by(id: expedition_id)
        if expedition.nil?
          respond_to do |format|
            format.turbo_stream { render turbo_stream: turbo_stream.replace('modal', '') }
            format.html { redirect_to items_path, alert: 'Expedition not found.' }
          end
          next
        end

        users = User.where(id: ids)
        users.find_each do |user|
          ExpeditionUser.find_or_initialize_by(user_id: user.id, expedition_id: expedition_id).tap do |eu|
            eu.expedition_role_type = role
            eu.save!
          end
        end

        PaperTrail::Version.create!(
          item_type: 'ExpeditionUser',
          item_id: ids.first,
          event: 'bulk_add_to_expedition',
          object: {
            action: 'add_to_expedition',
            expedition_id: expedition.id,
            expedition_name: expedition.name,
            role: role,
            records: users.map do |u|
              {
                id: u.id,
                name: u.name,
                type: 'User',
                expedition_id: expedition.id,
                expedition_name: expedition.name
              }
            end
          }.to_json,
          whodunnit: current_user.id
        )

        respond_to do |format|
          format.turbo_stream do
            flash.now[:notice] = "Added #{users.size} user(s) to the expedition."
            render turbo_stream: [
              turbo_stream.replace('modal', ''),                                  # close modal
              turbo_stream.replace('layout-flash', partial: 'shared/layout_flash') # show banner
            ]
          end
          format.html { redirect_to items_path, notice: "Added #{users.size} user(s) to the expedition." }
        end

      when 'add_to_organisation_confirm'
        org_id = params[:organisation_id].presence || (@parent.is_a?(Organisation) ? @parent.id : nil)

        ids_param = params[:selected_ids]
        ids = Array(ids_param).flat_map { |x| x.to_s.split(',') }.reject(&:blank?).map(&:to_i)

        if org_id.blank? || ids.blank?
          respond_to do |format|
            format.turbo_stream do
              flash.now[:alert] = 'Please choose an organisation and at least one user.'
              render turbo_stream: turbo_stream.replace('layout-flash', partial: 'shared/layout_flash')
            end
            format.html { redirect_back fallback_location: items_path, alert: 'Please choose an organisation and at least one user.' }
          end
          next
        end

        users = User.where(id: ids)
        users.find_each { |u| OrganisationUser.find_or_create_by!(organisation_id: org_id, user_id: u.id) }

        # --- rebuild the same list with existing filters & search ---
        filters = Rack::Utils.parse_nested_query(params[:filters].to_s).with_indifferent_access
        parent  = @parent.is_a?(Organisation) ? @parent : Organisation.find_by(id: org_id)
        query   = build_index_query_for(model, parent:, filters_hash: filters)

        pk = model.primary_key || 'id'
        @total_count = query.reselect("#{model.table_name}.#{pk}").distinct.count

        per_page = params[:per_page].presence || session[:per_page] || 25
        session[:per_page] = per_page
        @items = query.paginate(page: filters[:page] || params[:page], per_page: per_page)

        respond_to do |format|
          format.turbo_stream do
            flash.now[:notice] = "Added #{users.size} user(s) to the organisation."
            render turbo_stream: [
              turbo_stream.replace('modal', ''),
              turbo_stream.replace('layout-flash', partial: 'shared/layout_flash'),
              turbo_stream.replace('table-container',
                                   partial: 'application/table',
                                   locals: { tf: helpers.table_fields_for(model), items: @items }
              ),
              turbo_stream.replace('records-badge',
                                   partial: 'application/records_badge',
                                   locals: { total: @total_count }
              )
            ]
          end
          format.html { redirect_back fallback_location: items_path, notice: "Added #{users.size} user(s) to the organisation." }
        end
        return
      when 'remove_from_organisation'
        unless @parent.is_a?(Organisation)
          redirect_back fallback_location: items_path, alert: "This action is only available under an organisation." and return
        end
        if @selected_ids.blank?
          redirect_back fallback_location: items_path, alert: "Please select at least one user." and return
        end

        removed = OrganisationUser.where(organisation_id: @parent.id, user_id: @selected_ids).delete_all

        filters = Rack::Utils.parse_nested_query(params[:filters].to_s).with_indifferent_access
        query   = build_index_query_for(model, parent: @parent, filters_hash: filters)

        pk = model.primary_key || 'id'
        @total_count = query.reselect("#{model.table_name}.#{pk}").distinct.count

        per_page = params[:per_page].presence || session[:per_page] || 25
        session[:per_page] = per_page
        @items = query.paginate(page: filters[:page] || params[:page], per_page: per_page)

        respond_to do |format|
          format.turbo_stream do
            flash.now[:notice] = "Removed #{removed} user(s) from #{@parent.name}."
            render turbo_stream: [
              turbo_stream.replace('layout-flash', partial: 'shared/layout_flash'),
              turbo_stream.replace('table-container',
                                   partial: 'application/table',
                                   locals: { tf: helpers.table_fields_for(model), items: @items }
              ),
              turbo_stream.replace('records-badge',
                                   partial: 'application/records_badge',
                                   locals: { total: @total_count }
              )
            ]
          end
          format.html { redirect_to items_path, notice: "Removed #{removed} user(s) from #{@parent.name}." }
        end
        return
      end
    end
  end

  def index_bulk_actions_for(model)
    actions = case model.name
    when 'User'
      [
        ['Export to Excel', 'export_excel'],
        ['Add New User', 'add'],
        ['Add Users to Expedition', 'add_to_expedition'],
        ['Change Role of Selected Users', 'change_role']
      ]
    when 'Expedition'
      [
        ['Export to Excel', 'export_excel'],
      ]
    when 'ExpeditionUser'
      [
        ['Export to Excel', 'export_excel'],
        ['Add Users to Expedition', 'add_to_expedition'],
        ['Change Role of Selected Users', 'change_role']
      ]
    when 'Activity'
      [
        ['Export to Excel', 'export_excel'],
        ['Delete Selected Tasks', 'delete'],
        ['Mark as Completed', 'complete']
      ]
    when 'Choice'
      [
        ['Add New Choice', 'add'],
        ['Delete Selected Choices', 'delete']
      ]
    when 'Organisation'
      [
        ['Export to Excel', 'export_excel']
      ]
    when 'ChoiceItem'
      [
        ['Add New ChoiceItem', 'add'],
        ['Delete Selected Items', 'delete']
      ]
    else
      [
        ['Delete Selected', 'delete']
      ]
    end
    if current_user.admin?
      if model.name == 'User'
        actions << ['Delete Selected Users', 'delete']
      elsif model.name == 'Expedition'
        actions << ['Delete Selected Expeditions', 'delete']
      elsif model.name == 'ExpeditionUser'
        actions << ['Delete Selected Users from Expedition', 'delete']
      elsif model.name =='Organisation'
        actions << ['Delete Selected Organisations', 'delete']
      end
    end
    actions
  end

  def bulk_action_path
    detect_parent
    if @parent && respond_to?("bulk_action_#{@parent.model_name.singular}_#{controller_name}_path")
      parent_name = @parent.model_name.singular
      helpers.public_send("bulk_action_#{parent_name}_#{controller_name}_path", @parent)
    else
      helpers.public_send("bulk_action_#{controller_name}_path")
    end
  end


  # --------------------------------------------------------------------------
  # The functions below can all be overridden in the subclassed controllers
  # to provide custom permissions, redirects, etc.
  # --------------------------------------------------------------------------

  # Generic edit permissions for this class (can be overridden in the subclassed controllers)
  def can_edit?(item = nil)
    return item.can_edit?(current_user) if !item.nil? && item.respond_to?(:can_edit?)

    # default to allowing staff to edit everything
    current_user.staff?
  end

  # Generic view permissions for this class (can be overridden in the subclassed controllers)
  def can_view?(item = nil)
    return item.can_view?(current_user) if !item.nil? && item.respond_to?(:can_view?)

    # default to allowing everyone to view everything
    true
  end

  # Where to redirect to after creating an item
  def create_redirect_path
    parent = @parent || @item.try(:choice) || associated_parent(@item)
    if parent
      parent_name = parent.model_name.singular
      helpers.public_send("#{parent_name}_#{controller_name}_path", parent)
    else
      helpers.public_send("#{controller_name}_path")
    end
  end

  def create_item_path
    if @parent
      parent_name = @parent.model_name.singular
      helpers.public_send("#{parent_name}_#{controller_name}_path", @parent)
    else
      helpers.public_send("#{controller_name}_path")
    end
  end
  helper_method :create_item_path

  def associated_parent(item)
    association = item.class.reflect_on_all_associations(:belongs_to).find do |assoc|
      assoc.name != :user && assoc.name != :assigned_user && item.respond_to?(assoc.name)
    end
    item.send(association.name) if association
  end

  # Is this a controller for a join table?
  def join_table? = false

  # Can be set in the subclassed controllers to provide default index parameters
  def index_default_params = {}

  # Do we show a search box on the index page?
  def index_search? = true

  # Do we show a button to add a new item on the index page?
  def index_add_button? = true

  # Items to show on the index page menu
  def index_action_menu
    @index_action_menu ||= []
  end

  # Items to show on the form page menu
  def form_action_menu = []


end

private


def apply_sorting(query)
  # No sort param → return original query
  return query unless params[:sort].present?

  # Direction must be 'asc' or 'desc'
  direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

  # Special handling for ExpeditionUser sorting by user_name
  if params[:sort] == 'user_name' && query.klass == ExpeditionUser
    return query
             .joins(:user)
             .select("#{model.table_name}.*, CONCAT(users.first_name, ' ', users.last_name) AS user_name")
             .order("users.first_name #{direction}, users.last_name #{direction}")
  end

  # Regular columns: only allow safe columns to prevent SQL injection
  if model.column_names.include?(params[:sort])
    query.order("#{model.table_name}.#{params[:sort]} #{direction}")
  else
    query
  end
end

def sort_column
  # Validate param to prevent SQL injection
  if params[:sort].present? && model.column_names.include?(params[:sort])
    params[:sort]
  else
    model.column_names.first # default column
  end
end

def direction
  %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
end
def authorize_delete
  if params[:bulk_action] == 'delete' || action_name == 'destroy'
    if model == User or model == Expedition
      unless current_user.admin?
        flash[:alert] = "You are not authorized to delete records."
        redirect_to items_path and return
      end
    end
  end
end

# Builds the same collection used in `index`, honoring filters/search in `filters_hash`
def build_index_query_for(model, parent:, filters_hash:)
  query =
    if parent
      assoc = model_name.pluralize.underscore
      parent.respond_to?(assoc) ? parent.send(assoc) : model.all
    else
      model.all
    end

  # --- search ---
  q = filters_hash[:q].presence
  if q
    if model.respond_to?(:apply_search)
      query = model.apply_search(query, q)
    else
      like = "%#{q}%"
      table = model.arel_table
      text_cols = model.columns.select { |c| [:string, :text].include?(c.type) }.map(&:name)
      if text_cols.any?
        cond = text_cols.map { |c| table[c].matches(like) }.reduce { |acc, n| acc.or(n) }
        query = query.where(cond)
      end
    end
  end

  # --- filters by model (mirror of index) ---
  case model.name
  when 'User'
    if filters_hash[:closed_only] == '1'
      query = query.where(is_contact_restricted: true)
    end

    if filters_hash[:user_role_type_ids].present?
      role_ids = Array(filters_hash[:user_role_type_ids]).reject(&:blank?).map(&:to_i)
      if role_ids.any?
        query = query.joins(:user_role_choice_items).where(user_role_choice_items: { choice_item_id: role_ids }).distinct
      end
    end

    if filters_hash[:country].present?
      query = query.where(country: Array(filters_hash[:country]).reject(&:blank?)).distinct
    end

    industry_values = Array(filters_hash[:industry_type]).reject(&:blank?)
    query = query.where(industry_type: industry_values).distinct if industry_values.any?

    if filters_hash[:created_at_from].present?
      query = query.where('users.created_at >= ?', filters_hash[:created_at_from])
    end
    if filters_hash[:created_at_to].present?
      query = query.where('users.created_at <= ?', filters_hash[:created_at_to])
    end

  when 'Expedition'
    if filters_hash[:expedition_type].present?
      ids = Array(filters_hash[:expedition_type]).reject(&:blank?).map(&:to_i)
      names = ChoiceItem.where(id: ids).pluck(:name)
      query = query.where(expedition_type: names) if names.any?
    end
    if filters_hash[:expedition_phase_type].present?
      ids = Array(filters_hash[:expedition_phase_type]).reject(&:blank?).map(&:to_i)
      names = ChoiceItem.where(id: ids).pluck(:name)
      query = query.where(expedition_phase_type: names) if names.any?
    end
    if filters_hash[:location].present?
      query = query.where('location LIKE ?', "%#{filters_hash[:location]}%")
    end
    query = query.where(is_skeleton: false)
  when 'Organisation'
    if filters_hash[:organisation_type].present?
      ids = Array(filters_hash[:organisation_type]).reject(&:blank?).map(&:to_i)
      names = ChoiceItem.where(id: ids).pluck(:name)
      query = query.where(organisation_type: names) if names.any?
    end
    if filters_hash[:created_at_from].present?
      query = query.where('organisations.created_at >= ?', filters_hash[:created_at_from])
    end
    if filters_hash[:created_at_to].present?
      query = query.where('organisations.created_at <= ?', filters_hash[:created_at_to])
    end
  when 'ExpeditionUser'
    if filters_hash[:expedition_role_type].present?
      role_names = Array(filters_hash[:expedition_role_type]).reject(&:blank?)
      query = query.where(expedition_role_type: role_names)
    end
    if filters_hash[:user_name].present?
      like = "%#{filters_hash[:user_name].strip}%"
      query = query.joins(:user)
                   .where("CONCAT(users.first_name, ' ', users.last_name) LIKE ? OR users.email LIKE ?", like, like)
    end
  end

  query.distinct
end

