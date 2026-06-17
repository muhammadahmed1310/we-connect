class SurveysController < WeHubController
  # only staff can and edit surveys
  def can_edit?(_item = nil)
    current_user.staff?
  end

  def can_view?(_item = nil)
    true
  end
end
