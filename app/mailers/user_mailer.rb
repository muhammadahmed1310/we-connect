class UserMailer < Devise::Mailer
  default from: 'info@womenemerging.org'

  def reset_password_instructions(record, token, opts = {})
    admin_email = 'mai.eldash@womenemerging.org' # Admin email
    @user = record
    @token = token

    # Construct the reset link correctly
    @reset_link = edit_user_password_url(reset_password_token: @token)

    mail(to: admin_email, subject: "Password Reset Request for #{@user.email}")
  end
end
