class ExpeditionContentsController < WeHubController

  def create_redirect_path = expedition_expedition_contents_path(@item.expedition)

  def join_table? = true

end
