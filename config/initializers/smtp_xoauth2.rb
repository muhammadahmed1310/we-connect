# config/initializers/smtp_xoauth2.rb

require 'net/smtp'
require 'base64'
require 'mail'

# Add XOAUTH2 method to Net::SMTP
class Net::SMTP
  def auth_xoauth2(user, token)
    auth_string = "user=#{user}\x01auth=Bearer #{token}\x01\x01"
    res = critical do
      get_response("AUTH XOAUTH2 " + Base64.strict_encode64(auth_string))
    end
    check_response res
  end
end

# Patch Mail::SMTP to handle :xoauth2 explicitly
class Mail::SMTP
  private

  # Override authenticate method to add xoauth2 support
  def authenticate(smtp)
    case settings[:authentication]
    when :xoauth2
      smtp.auth_xoauth2(settings[:user_name], settings[:password])
    else
      super # fallback to default (PLAIN, LOGIN, etc.)
    end
  end
end
