class ExpeditionOrganisationsController < WeHubController

  def create_redirect_path = expedition_expedition_organisations_path(@item.expedition)

  def join_table? = true

end
