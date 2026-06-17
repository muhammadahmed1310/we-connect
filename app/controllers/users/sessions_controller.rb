# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    # def create
    #   super
    # end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
    # app/controllers/users/sessions_controller.rb (if overridden)
    def create
      user = User.find_by(email: params[:user][:email])
      if user&.is_contact_only?
        flash[:alert] = "This user is a contact and cannot log in."
        redirect_to new_user_session_path
      else
        super
      end
    end

    Warden::Manager.after_authentication do |user, auth, opts|
      PaperTrail.request.whodunnit = user.id
      PaperTrail::Version.create!(
        item_type: 'User',
        item_id: user.id,
        event: 'login',
        whodunnit: user.id,
        object: user.to_json
      )
    end

  end
end
