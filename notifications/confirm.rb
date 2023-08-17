# Notification to deliver when a new user signups, or a new user is added to an exisitng account.
module BlackStack
  module MySaaS
    class NotificationConfirm < BlackStack::MySaaS::Notification 
      LINK_TIMEOUT = 18

      def initialize(i_user)
        super(i_user)
        self.type = 2
      end
      
      def subject_template
        "Confirm Your Email Address."
      end

      def body_template
        " 
          <p>Dear #{self.user.name.encode_html},</p>

          <p>We sent this email to you becuase you created an account in <a href='#{CS_HOME_WEBSITE}'><b>#{APP_NAME}</b></a>.</p>

          <p><b>Click the link below to confirm your email address.</b></p>
          
          <p>This link will be valid for #{BlackStack::MySaaS::NotificationConfirm::LINK_TIMEOUT.to_s} minutes.</p>
          
          <p><a href='#{CS_HOME_WEBSITE}/confirm/#{self.id.to_guid}'><b>Click here and confirm your email address</b></a>.</p>
          
          <br/>
          
          <p>Email address confirmation is a neccesary step to unlock most of the #{APP_NAME} features.</p>
          <p>If the link above is no longer available, you can request a new confirmation link <a href='#{CS_HOME_WEBSITE}/settings/users'><b>here</b></a>.</p>
        "
      end
    end
  end # module MySaaS
end # module BlackStack