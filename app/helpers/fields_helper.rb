# app/helpers/fields_helper.rb
module FieldsHelper
  delegate :join_table?,        to: :controller
  delegate :index_search?,      to: :controller
  delegate :index_add_button?,  to: :controller
  delegate :index_action_menu,  to: :controller

  def table_fields_for(model)
    _construct_fields(table_names_for(model), model, for_table: true)
  end
  # Normalize any role/text value to "Camel Case" for UI
  def camel_label(val)
    return '' if val.blank?
    s =
      case val
      when String       then val
      when Symbol       then val.to_s
      when respond_to?(:name) ? val : nil # ChoiceItem or AR with .name
        val.name.to_s
      else
        val.to_s
      end
    s.tr('_', ' ').gsub(/\s+/, ' ').strip.titleize
  end

  def camel_join(vals)
    Array(vals).map { |v| camel_label(v) }.reject(&:blank?).join(', ')
  end


  def form_fields_for(item, parent: nil)
    fields = _construct_fields(field_names_for(item.class), item.class, parent: parent)

    if item.is_a?(User)
      # Replace single organisation with multi-select Organisations (tom-select + quick-add)
      if fields['organisation']
        f = fields['organisation']
        f['label']        = 'Organisations'
        f['name']         = 'organisation_ids'
        f['as']           = 'select'
        f['collection']   = Organisation.order(:name).pluck(:name, :id)
        f['value_method'] = 'second'
        f['label_method'] = 'first'

        f['input_html'] ||= {}
        f['input_html'][:multiple] = true
        f['input_html'][:data]   ||= {}
        f['input_html'][:data].merge!(
          controller: 'org-select',
          'org-select-create-url-value': Rails.application.routes.url_helpers.organisations_path(format: :json),
          'org-select-modal-id-value':   'new-organisation-modal',
          'org-select-add-label-value':  '+ Add new organisation',
          'org-select-target':           'select',
          max_items: 6
        )
      else
        # Fallback: if 'organisation' isn't in field_names, inject after linkedin_url (or before notes)
        multi = {
          'label'        => 'Organisations',
          'name'         => 'organisation_ids',
          'as'           => 'select',
          'collection'   => Organisation.order(:name).pluck(:name, :id),
          'value_method' => 'second',
          'label_method' => 'first',
          'input_html'   => {
            multiple: true,
            data: {
              controller: 'org-select',
              'org-select-create-url-value': Rails.application.routes.url_helpers.organisations_path(format: :json),
              'org-select-modal-id-value':   'new-organisation-modal',
              'org-select-add-label-value':  '+ Add new organisation',
              'org-select-target':           'select',
              max_items: 6
            }
          }
        }

        pairs = fields.to_a
        after_key = %w[linkedin_url secondary_email country industry_type].find { |k| fields.key?(k) }
        idx = pairs.index { |(k, _)| k == after_key } || pairs.index { |(k, _)| k == 'notes' } || (pairs.length / 2)
        pairs.insert((idx || 0) + 1, ['organisations', multi])
        fields = pairs.to_h
      end

      fields['is_contact_only'] = {
        'label' => 'Contact only (no login access)',
        'name'  => 'is_contact_only',
        'as'    => 'boolean',
        'input_html' => {
          data: {
            controller: 'contact-toggle',
            action: 'change->contact-toggle#toggle',
            'contact-toggle-target': 'flag'
          }
        }
      }

      if item.created_by.present?
        fields['created_by'] = {
          'label'    => 'Created by',
          'name'     => 'created_by_id',
          'as'       => 'string',
          'disabled' => true,
          'readonly' => true,
          'value'    => "#{item.created_by.name}, #{item.created_at&.strftime('%B %-d, %Y')}"
        }
      else
        fields.delete('created_by')
      end

      actor = controller.current_user

      # NEW: show owner on all NEW users (JS will hide it when Contact only is off)
      # and on existing contacts (same as outreach behaviour)
      show_owner = item.new_record? || item.contact?

      if show_owner
        owners_source = User.joins(:user_role_types)
                            .where(choice_items: { name: %w[staff administrator] })
                            .pluck(Arel.sql('DISTINCT users.id'), :first_name, :last_name)
                            .map { |id, fn, ln| ["#{fn} #{ln}", id] }
                            .sort_by { |name, _| name.downcase }

        can_edit_owner = item.new_record? || item.can_change_owner?(actor)

        fields['owner'] = {
          'label'        => 'Owner',
          'name'         => 'owner_id',
          'as'           => 'select',
          'collection'   => owners_source,
          'value_method' => 'second',
          'label_method' => 'first',
          'disabled'     => !can_edit_owner,
          'readonly'     => !can_edit_owner
        }

        # 🔴 make Owner a contact-toggle "panel" target (same as outreach)
        fields['owner']['input_html']           ||= {}
        fields['owner']['input_html'][:data]    ||= {}
        fields['owner']['input_html'][:data]['contact-toggle-target'] = 'panel'
      else
        fields.delete('owner')
      end


      # --- Reach permission: render on NEW and on EDIT (contacts), let Stimulus show/hide based on "Contact only" ---
      will_be_owner =
        item.new_record? &&
          (
            controller.params.dig(:user, :owner_id).blank? ||    # will default to creator
              controller.params.dig(:user, :owner_id).to_i == actor.id
          )

      can_toggle_now =
        item.new_record? ? (true) : item.can_change_closed_flag?(actor) # always allow on NEW; controller still enforces

      if item.new_record? || item.contact?
        fields['is_contact_restricted'] = {
          'label' => 'Closed to outreach (permission required)',
          'name'  => 'is_contact_restricted',
          'as'    => 'boolean',
          'hint'  => 'Only applied if “Contact only” is checked.',
          'input_html' => {
            class: 'contact-permission-input',
            data: { 'contact-toggle-target': 'panel' },
            disabled: (!can_toggle_now && !item.new_record?),
            readonly: (!can_toggle_now && !item.new_record?)
          }

        }
      end

      # Password fields: inline only for new login users (modal elsewhere for edit)
      if item.login_user?
        if item.new_record?
          fields['password'] ||= {
            'as'         => 'password',
            'required'   => true,
            'label'      => 'Password',
            'input_html' => { autocomplete: 'new-password' },
            'hint'       => 'Set a password for this account.'
          }
          fields['password_confirmation'] ||= {
            'as'         => 'password',
            'required'   => true,
            'label'      => 'Confirm password',
            'input_html' => { autocomplete: 'new-password' },
            'hint'       => 'Re-enter the password.'
          }
          fields.delete('current_password')
        else
          fields.delete('password')
          fields.delete('password_confirmation')
          fields.delete('current_password')
        end
      else
        fields.delete('password')
        fields.delete('password_confirmation')
        fields.delete('current_password')
      end
    end

    if item.is_a?(Activity)
      if fields['activity_type']
        fields['activity_type']['name']         = 'activity_type_id'
        fields['activity_type']['as']           = 'select'
        fields['activity_type']['collection']   = Choice.select_options_for('activity_type', raw: true).map { |ci| [camel_label(ci.name), ci.id] }
        fields['activity_type']['label_method'] = 'first'
        fields['activity_type']['value_method'] = 'second'
      end

      if fields['activity_status_type']
        fields['activity_status_type']['name']         = 'activity_status_type_id'
        fields['activity_status_type']['as']           = 'select'
        fields['activity_status_type']['collection']   = Choice.select_options_for('activity_status_type', raw: true).map { |ci| [camel_label(ci.name), ci.id] }
        fields['activity_status_type']['label_method'] = 'first'
        fields['activity_status_type']['value_method'] = 'second'
      end
    end
    if fields['nationality']
      fields['nationality']['collection'] = ISO3166::Country.all.map(&:iso_short_name)
      fields['nationality']['as']         = 'select'
    end
    if fields['country']
      fields['country']['collection'] = ISO3166::Country.all.map(&:iso_short_name)
      fields['country']['as']         = 'select'
    end
    if fields['organisation']
      fields['organisation']['collection']             = Organisation.order(:name).pluck(:name, :id)
      fields['organisation']['as']                     = 'select'
      fields['organisation']['label']                  = 'Organisation'
      fields['organisation']['input_html']           ||= {}
      fields['organisation']['input_html']['data']   ||= {}
      fields['organisation']['input_html']['data']['org-select-target'] = 'select'
    end

    fields
  end

  def field_names_for(model)
    if model.respond_to?(:field_names)
      model.field_names
    elsif model.respond_to?(:skip_fields)
      model.columns.map(&:name) - model.skip_fields
    else
      model.columns.map(&:name)
    end
  end

  def table_names_for(model)
    if model.respond_to?(:table_names)
      model.table_names
    elsif model.respond_to?(:skip_table_fields)
      model.columns.map(&:name) - model.skip_fields
    else
      model.columns.map(&:name) - %w[id created_at updated_at]
    end
  end

  def table_edit_fields_for(model)
    model.respond_to?(:table_edit_fields) ? model.table_edit_fields : []
  end

  def sub_records_for(item)
    if item.class.respond_to?(:sub_records)
      item.class.sub_records
    else
      item.class.reflect_on_all_associations(:has_many).map(&:name)
    end
  end

  def association_for(name, model = controller.model)
    assoc = model.reflect_on_association(name.to_s.downcase.pluralize.to_sym)
    assoc ||= model.reflect_on_association(name.to_s.downcase.singularize.to_sym)
    assoc
  end

  def through_association?(name, model)
    association_for(name, model)&.through_reflection?
  end

  def through_association_model(name, model)
    association_for(name, model)&.through_reflection&.klass
  end

  def has_many_association?(name, model)
    association_for(name, model)&.collection?
  end

  def belongs_to_association?(name, model)
    association_for(name, model).is_a?(ActiveRecord::Reflection::BelongsToReflection)
  end

  def parent_id_field_name
    "#{@parent.class.to_s.underscore.downcase}_id"
  end

  private

  def _construct_fields(names, model, parent: nil, for_table: false)
    h = {}

    names.each do |n|
      next if h.key?(n)

      h[n] = { 'label' => _title_for(n, model), 'name' => n }
      h[n]['sort_key'] = 'first_name' if n == 'name' && model == User

      v = model.columns_hash[n]

      if v # real column
        # TABLE: for *_type show ChoiceItem name even if DB still has an id
        if for_table && n.ends_with?('_type')
          h[n]['value'] = ->(item) do
            val = item[n]
            next '' if val.blank?
            val.to_s =~ /\A\d+\z/ ? (ChoiceItem.find_by(id: val)&.name || val) : val
          end
        end

        # Per-type widget hints
        case v.type
        when :datetime, :date
          h[n]['as'] = 'timepicker'
        when :text
          h[n]['as'] = :html
        when :integer
          if %w[activity_type_id activity_status_type_id].include?(n)
            choice_name            = n == 'activity_type_id' ? 'activity_type' : 'activity_status_type'
            h[n]['as']             = 'select'
            h[n]['collection']     = Choice.select_options_for(choice_name)
            h[n]['value_method']   = 'id'
            h[n]['label_method']   = 'name'
          end
        end
      else
        # Association field
        assoc = association_for(n, model)
        if assoc
          h[n]['type'] = 'association'
          if for_table
            h[n]['as'] = 'link'
            if belongs_to_association?(n, model)
              h[n]['link_text'] = ->(item) { item.send(n.to_sym)&.name }
              h[n]['path']      = ->(item) { _item_path(item, n) }
            else
              h[n]['link_text'] = ->(_item) { _title_for(n, model) }
              h[n]['path']      = ->(item) { polymorphic_path([item, n.to_sym]) }
            end
          else
            h[n]['name'] = if model.reflect_on_association(n.to_sym)&.collection? && through_association?(n, model)
                             "#{n.singularize}_ids"
                           else
                             "#{n}_id"
                           end
            h[n]['collection'] = Choice.reference_choices(model, n, parent: parent)
          end
        else
          h[n]['disabled'] = true
        end
      end

      # Labels for booleans
      h[n]['label'] = "#{n.gsub(/^is_/, '')}?".titleize if n.starts_with?('is_')

      # --- TYPE FIELDS (shared behaviour) ---
      # inside _construct_fields(...) where we handle *_type / *_types

      if n.ends_with?('_type') || n.ends_with?('_types')
        h[n]['label'] = _type_label(n, model)

        items = Choice.select_options_for(n.singularize, raw: true) # AR list of ChoiceItem

        if n.ends_with?('_types') && model.reflect_on_association(n.to_sym)&.collection? && through_association?(n, model)
          # Multi-select (checkboxes)
          h[n]['as']         = 'check_boxes'
          h[n]['collection'] = items.map { |ci| [camel_label(ci.name), ci.id] }
          h[n]['label_method'] = 'first'
          h[n]['value_method'] = 'second'
          h[n]['name']         = "#{n.singularize}_ids"
        else
          # Single select — store the NAME string
          h[n]['as']         = 'select'
          h[n]['collection'] = items.map { |ci| [camel_label(ci.name), ci.name] }
          h[n]['label_method'] = 'first'
          h[n]['value_method'] = 'second'
        end
      end

      if model.name == 'ExpeditionUser' && n == 'expedition_role_type'
        h[n]['value'] = ->(eu) { camel_label(eu.expedition_role_type) }
      end
      if model == User
        case n
        when 'owner'
          h[n]['type']      = 'string'
          h[n]['as']        = 'text'
          h[n]['value']     = ->(item) { item.owner&.full_name }
          h[n]['sortable']  = false
        when 'contact_permission'
          h[n]['type']      = 'string'
          h[n]['as']        = 'text'
          h[n]['value']     = ->(item) { item.closed_to_outreach? ? 'Closed' : 'Open' }
          h[n]['sortable']  = false
        end
      end


      if n.starts_with?('password')
        h[n]['as']      = 'password'
        h[n]['disabled']= false
      end

      if for_table && %w[name email].include?(n)
        h[n]['as']        ||= 'link'
        h[n]['link_text'] ||= ->(item) { item.send(n.to_sym) }
        h[n]['path']      ||= ->(item) { url_for(item) }
      end

      if model.name == 'User' && (n == 'user_role_types' || n == 'user_role_type_ids')
        h[n] ||= { 'label' => _title_for(n, model), 'name' => 'user_role_type_ids' }
        items = Choice.select_options_for('user_role_type', raw: true)
        h[n]['as']           = :check_boxes
        h[n]['collection']   = items.map { |ci| [camel_label(ci.name), ci.id] }
        h[n]['label_method'] = 'first'
        h[n]['value_method'] = 'second'
        h[n]['name']         = 'user_role_type_ids'
        h[n]['sortable']     = false
        h[n].delete('disabled')
      end


      if model.name == 'ExpeditionUser' && n == 'user'
        h[n]               ||= {}
        h[n]['as']          = 'link'
        h[n]['link_text']   = ->(item) { item.user&.name }
        h[n]['path']        = ->(item) { polymorphic_path(item.user) }
        h[n]['sortable']    = true
        h[n]['value']       = ->(item) { item.try(:user)&.name || "#{item.user&.first_name} #{item.user&.last_name}" }
        h[n]['sort_key']    = 'user_name'
        h[n]['fallback_to_sort_col'] = true
      end

      h[n]['disabled'] = true if %w[created_at updated_at id].include?(n)

      if through_association?(n, model)
        h[n]['as']    = 'text'
        h[n]['value'] = ->(item) { camel_join(item.send(n).map { |r| r.respond_to?(:name) ? r.name : r }) }
      end
    end

    h.each_value do |field|
      next unless field['collection'].present?
      if field['collection'].first.is_a?(Array)
        field['collection'] = field['collection'].sort_by { |(lbl, _)| lbl.to_s.downcase }
      else
        field['collection'] = field['collection'].sort_by(&:to_s)
      end
    end

    h
  end

  def _item_path(item, n)
    v = item.send(n)
    v.nil? ? '' : polymorphic_path(v)
  end

  def _type_label(name, model)
    t = name.gsub(/_type$/, '').gsub(model.to_s.downcase, '')
    return 'Type' if t.blank?
    t.titleize
  end

  def _title_for(name, model)
    n = name
    n = n.gsub(model.to_s.underscore.downcase, '') if model
    n.titleize
  end

  def display_field_value(obj, field)
    value = obj.send(field)

    # Show ChoiceItem name for *_type whether DB has id or name
    if field.to_s.ends_with?('_type') && value.present?
      raw =
        ChoiceItem.find_by(id: value)&.name ||
          ChoiceItem.find_by(name: value)&.name ||
          value
      return camel_label(raw)
    end

    # Many-to-many associations → list of names (CamelCase)
    if value.is_a?(ActiveRecord::Associations::CollectionProxy)
      return camel_join(value.map { |r| r.respond_to?(:name) ? r.name : r })
    end

    value
  end
end
