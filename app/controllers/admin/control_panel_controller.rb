# app/controllers/admin/control_panel_controller.rb
class Admin::ControlPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def choices
    @choices = Choice.all
    render :index
  end

  def logs
    @versions = PaperTrail::Version
                .includes(:item)
                .order(created_at: :desc)
                .paginate(page: params[:page], per_page: 100)

    render :index
  end



  private

  def authorize_admin!
    redirect_to root_path, alert: 'Access denied' unless current_user&.admin?
  end
end
