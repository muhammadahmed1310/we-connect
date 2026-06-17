class VersionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @versions = PaperTrail::Version.order(created_at: :desc).page(params[:page]).per(20)
  end

  def version
    @version = PaperTrail::Version.find(params[:id])
    @item = @version.reify
    @item ||= @version.item_type.safe_constantize&.find_by(id: @version.item_id)
  end

end
