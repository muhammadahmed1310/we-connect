ActiveSupport.on_load(:action_mailer) do
  ActionMailer::Base.register_interceptor(
    Class.new do
      def self.delivering_email(message)
        # Inject fresh token just before sending
        settings = message.delivery_method.settings
        settings[:password] = AzureOauthSmtp.fetch_token
      end
    end
  )
end
