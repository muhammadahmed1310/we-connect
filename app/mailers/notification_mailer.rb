class NotificationMailer < ApplicationMailer
  default from: "no-reply@womenemerging.org"

  def task_assigned(user, activity, assigner)
    @user = user
    @activity = activity
    @assigner = assigner
    mail(
      to: @user.email,
      subject: "New Task Assigned: #{@activity.name}"
    )
  end

end
