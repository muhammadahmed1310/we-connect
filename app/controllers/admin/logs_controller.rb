# app/controllers/admin/logs_controller.rb
class Admin::LogsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @versions = PaperTrail::Version
                  .includes(:item)
                  .order(created_at: :desc)
                  .limit(200)
  end

  def authorize_admin!
    redirect_to root_path, alert: 'Access denied' unless current_user.admin?
  end
end
