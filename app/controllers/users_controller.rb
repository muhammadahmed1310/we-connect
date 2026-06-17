  class UsersController < WeHubController

    def default_index_params = {is_active: true, is_deleted: false}
    def create_redirect_path = users_path

    def index_action_menu
      return @index_action_menu if defined?(@index_action_menu)

      if @parent.is_a?(Organisation)
        @index_action_menu = [
          { label: 'Add Users to Organisation',
            data: { controller: 'bulk-action', action: 'click->bulk-action#submitFromMenu', 'bulk-action-action-value': 'add_to_organisation' } },
          {
            label: 'Delete Selected Users from Organisation',
            data: {
              controller: 'bulk-action',
              action: 'click->bulk-action#submitFromMenu',
              'bulk-action-action-value': 'remove_from_organisation'
            }
          },
          {
            label: 'Export to Excel',
            data: {
              controller: 'bulk-action',
              action: 'click->bulk-action#submitFromMenu',
              'bulk-action-action-value': 'export_excel'
            }
          }
        ]
        return @index_action_menu
      end


      menu = [

        [
          label: 'Batch Users Upload',
          id: 'batch_users_upload',
          partial: 'batch_user_upload'
        ]
      ]

      @bulk_actions ||= index_bulk_actions_for(User).map do |label, action|
        {
          label: label,
          url: bulk_action_path,
          data: {
            controller: 'bulk-action',
            action: 'click->bulk-action#submitFromMenu',
            "bulk-action-action-value": action,
            turbo_method: :post
          }
        }
      end

      @index_action_menu = @bulk_actions + menu
    end

    def create
      selected_ids = params[:selected_ids]
      selected_ids = selected_ids.is_a?(Array) ? selected_ids.compact_blank : selected_ids.to_s.split(',').compact_blank

      expedition_id = params[:expedition_id]
      role = params[:expedition_role_type]

      # Only handle expedition user creation if we have valid expedition parameters
      if selected_ids.present? && expedition_id.present? && role.present? && !expedition_id.blank? && !role.blank?
        selected_ids.each do |user_id|
          ExpeditionUser.find_or_initialize_by(user_id: user_id, expedition_id: expedition_id).tap do |eu|
            eu.expedition_role_type = role
            eu.save!
          end
        end
        users = User.where(id: selected_ids)
        PaperTrail::Version.create!(
          item_type: 'ExpeditionUser',
          event: 'bulk_add_to_expedition',
          item_id: selected_ids.first,
          object: {
            action: 'add_to_expedition',
            expedition_id: expedition_id,
            expedition_name: Expedition.find_by(id: expedition_id)&.name,
            role: role,
            records: users.map { |u| { id: u.id, name: u.name, type: 'User' } }
          }.to_json,
          whodunnit: current_user.id
        )

        redirect_to users_path, notice: 'Users added to expedition.' and return
      end

      # else: normal user creation
      super do |success|
        # After the record is saved (and roles mass-assigned), enforce the Guide defaults:
        @item.send(:apply_guide_defaults_if_needed!) if success && @item.is_a?(User)
      end
    end

    def change_role
      ids = Array(params[:selected_ids] || params[:selected_ids[]]).reject(&:blank?)
      roles = Array(params[:role_choice_item_ids]).reject(&:blank?)

      if ids.blank? || roles.blank?
        redirect_to request.referer || users_path, alert: 'Missing required params' and return
      end

      if params[:expedition_id].present?
        eus = ExpeditionUser.includes(:expedition_role_type).where(user_id: ids, expedition_id: params[:expedition_id])
        old_roles = eus.index_by(&:user_id).transform_values { |eu| eu.expedition_role_type&.name || '—' }
        eus.each { |eu| eu.update!(expedition_role_type: roles.first) }
        updated = ExpeditionUser.includes(:expedition_role_type).where(user_id: ids, expedition_id: params[:expedition_id])
        new_roles = updated.index_by(&:user_id).transform_values { |eu| eu.expedition_role_type&.name || '—' }
        PaperTrail::Version.create!(
          item_type: 'ExpeditionUser',
          event: 'bulk_change_role',
          item_id: ids.first,
          object: {
            action: 'change_role',
            records: ids.map do |id|
              {
                id: id,
                name: User.find(id).name,
                type: 'User',
                from: Array.wrap(old_roles[id] || '').reject(&:blank?),
                to: Array.wrap(new_roles[id] || '').reject(&:blank?)
              }
            end
          }.to_json,
          whodunnit: current_user.id
        )
      else
        users = User.where(id: ids).includes(:user_role_types).to_a

        # 1. Capture roles before
        old_roles = users.index_with { |u| u.user_role_types.map(&:name) }
        # 2. Update roles
        users.each do |u|
          combined_roles = (u.user_role_type_ids + roles.map(&:to_i)).uniq
          u.user_role_type_ids = combined_roles
          u.save!
          u.send(:apply_guide_defaults_if_needed!)

        end

        records = ids.map do |id|
          user = User.find(id).tap(&:reload)
          puts "🔍 Before: #{old_roles[id]}"
          puts "✅ After: #{user&.user_role_types&.map(&:name)}"
          {
            id: id,
            name: user.name,
            type: 'User',
            from: Array(old_roles[id]).presence || ['—'],
            to: user.user_role_types.map(&:name).presence || ['—']
          }
        end



        PaperTrail::Version.create!(
          item_type: 'User',
          item_id: ids.first,
          event: 'bulk_change_role',
          object: {
            action: 'change_role',
            records: records
          }.to_json,
          whodunnit: current_user.id
        )

      end
      puts PaperTrail::Version.last.object

      redirect_to request.referer || users_path, notice: 'Roles updated for selected users.'
    end

    def batch_upload
      if params[:file].nil?
        flash[:error] = 'Please upload the contacts sheet'
        redirect_to users_path and return
      end

      service = ExcelUploadService.new(params[:file], User, UserParsing, current_user: current_user)
      result = service.call || { success: false, message: 'Unknown error', errors: [] }

      alert_message = result[:message]
      errors_summary = result[:errors].present? ? result[:errors].first(6).join("\n") : nil
      alert_message += "\n#{errors_summary}" if errors_summary

      redirect_to users_path, alert: alert_message
    end

    # For bulk adding users to expeditions
    def add_to_expedition
      selected_ids = params[:selected_ids]
      selected_ids = selected_ids.is_a?(Array) ? selected_ids.compact_blank : selected_ids.to_s.split(',').compact_blank
      expedition_id = params[:expedition_id]
      role = params[:expedition_role_type]

      if selected_ids.empty? || expedition_id.blank? || role.blank?
        redirect_to users_path, alert: 'Please select at least one user' and return
      end

      expedition = Expedition.find_by(id: expedition_id)
      if expedition.nil?
        redirect_to users_path, alert: 'Expedition not found.' and return
      end

      selected_ids.each do |user_id|
        ExpeditionUser.find_or_initialize_by(user_id: user_id, expedition_id: expedition_id).tap do |eu|
          eu.expedition_role_type = role
          eu.save!
        end
      end
      users = User.where(id: selected_ids)
      PaperTrail::Version.create!(
        item_type: 'ExpeditionUser',
        item_id: selected_ids.first,
        event: 'bulk_add_to_expedition',
        object: {
          action: 'add_to_expedition',
          expedition_id: expedition.id,
          expedition_name: expedition.name,
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


      redirect_to users_path, notice: 'Users added to expedition.'
    end

    def update
      wants_password =
        params.dig(model_name, :password).present? ||
          params.dig(model_name, :password_confirmation).present?

      if wants_password
        changing_self = (@item.id == current_user.id)
        unless current_user.admin? || !changing_self
          current = params[model_name][:current_password].to_s
          unless @item.valid_password?(current)
            @item.errors.add(:current_password, 'is incorrect')
            flash.now[:alert] = @item.errors.full_messages.to_sentence
            respond_to do |format|
              format.turbo_stream { render :edit, formats: :html, status: :unprocessable_entity }
              format.html        { render :edit, status: :unprocessable_entity }
              format.json        { render json: @item.errors, status: :unprocessable_entity }
            end
            return
          end

        end
        params[model_name].delete(:current_password)
      end

      was_guide = @item.guide?  # ← snapshot before update

      super do |success|
        # Run only when the role "Guide" was just added
        if success && !was_guide && @item.guide?
          @item.send(:apply_guide_defaults_if_needed!)
        end
      end
    end

    def destroy
      unless current_user.admin?
        redirect_to users_path, alert: "Only admins can delete users." and return
      end
      super
    end

    def password_modal
      @item = User.find(params[:id])
      return head :forbidden unless current_user.admin? || current_user.id == @item.id

      unless turbo_frame_request?
        redirect_to edit_user_path(@item) and return
      end

      force = params[:force_set_password].to_s == "1"
      render partial: 'users/password_modal', formats: [:html],
             locals: { force_set_password: force }
    end

    # app/controllers/users_controller.rb
    def update_password
      @item = User.find(params[:id])
      changing_self = current_user.id == @item.id
      allowed = current_user.admin? || changing_self
      return head :forbidden unless allowed

      force = params[:force_set_password].to_s == "1"

      cp       = params.require(:user).permit(:current_password, :password, :password_confirmation)
      current  = cp[:current_password].to_s
      new_pass = cp[:password].to_s
      new_conf = cp[:password_confirmation].to_s

      if changing_self && !current_user.admin? && !@item.valid_password?(current)
        @item.errors.add(:current_password, 'is incorrect')
      end
      if new_pass.blank?
        @item.errors.add(:password, "can't be blank")
      elsif new_pass != new_conf
        @item.errors.add(:password_confirmation, "doesn't match Password")
      end

      if @item.errors.empty?
        User.transaction do
          attrs = { password: new_pass, password_confirmation: new_conf }
          attrs[:is_contact_only] = false if force   # ✅ convert in SAME update

          @item.update!(attrs)
        end
      end


      respond_to do |format|
        format.turbo_stream do
          if @item.errors.any?
            render turbo_stream: turbo_stream.replace(
              'password-modal',
              partial: 'users/password_modal',
              locals: { force_set_password: force }
            ), status: :unprocessable_entity
          else
            flash.now[:notice] = force ? 'Password set. User can now log in.' : 'Password updated.'
            render turbo_stream: [
              turbo_stream.update('password-modal', ''),
              turbo_stream.replace('layout-flash', partial: 'shared/layout_flash'),
              # Optional: keep UI consistent immediately
              turbo_stream.append('body-end', <<~HTML.html_safe)
            <script>
              const cb = document.querySelector('input[type="checkbox"][name$="[is_contact_only]"]');
              if (cb) { cb.checked = false; cb.dispatchEvent(new Event("change", {bubbles:true})); }
            </script>
          HTML
            ]
          end
        end

        format.html do
          if @item.errors.any?
            redirect_to edit_user_path(@item), alert: @item.errors.full_messages.to_sentence
          else
            redirect_to edit_user_path(@item), notice: (force ? 'Password set. User can now log in.' : 'Password updated.')
          end
        end
      end
    end


    def can_change_owner?(record)
      return false unless record.is_a?(User)
      current_user.admin? || record.owner_id == current_user.id
    end
    def item_params
      p = super
      is_new_record   = @item.nil?
      is_contact_flag = ActiveModel::Type::Boolean.new.cast(p[:is_contact_only])
      p[:is_contact_only] = is_contact_flag

      # ✅ Decide stripping by the SUBMITTED flag only
      if is_contact_flag
        p.delete(:password)
        p.delete(:password_confirmation)
        p.delete(:current_password)
      else
        # On UPDATE: only keep password fields if user actually provided them,
        # but do NOT delete them just because the record USED TO be a contact.
        unless is_new_record
          if p[:password].blank? && p[:password_confirmation].blank?
            p.delete(:password)
            p.delete(:password_confirmation)
          end
          p.delete(:password_confirmation) if p[:password_confirmation].blank?
          p.delete(:current_password)
        end
      end

      # Default owner for new contacts only
      if is_new_record && is_contact_flag && p[:owner_id].blank?
        p[:owner_id] = current_user.id
      end

      role_ids = p.delete(:user_role_type_ids)
      @role_choice_items = ChoiceItem.where(id: Array(role_ids).reject(&:blank?)) if role_ids
      p[:user_role_type_ids] = role_ids if role_ids

      p
    end


    def index_add_button? = false
  end
