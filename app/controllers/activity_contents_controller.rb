class ActivityContentsController < WeHubController

  def create_redirect_path = activity_activity_contents_path(@item.activity)

  def join_table? = true

end
