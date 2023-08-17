module BlackStack
  module MySaaS
    class NotificationReset < BlackStack::MySaaS::Notification
      LINK_TIMEOUT = 18 # minutes
      
      def initialize(i_user)
        super(i_user)
        self.type = 3
      end

      def subject_template
        "Password Reset."
      end

      def body_template
        " 
          <p>Dear #{self.user.name.encode_html},</p>

          <p>You requested to reset your password in <a href='#{CS_HOME_WEBSITE}'><b>#{APP_NAME}</b></a>.</p>

          <p><b>Click the link below to reset your password.</b></p>
          
          <p>This link will be valid for #{BlackStack::MySaaS::NotificationReset::LINK_TIMEOUT.to_s} minutes.</p>
          
          <p><a href='#{CS_HOME_WEBSITE}/reset/#{self.id.to_guid}'><b>Click here to reset your password</b></a>.</p>
          
          <br/>
          
          <p>If the link above is no longer available, you can request a new confirmation link <a href='#{CS_HOME_WEBSITE}/recover'><b>here</b></a>.</p>
        "
      end
    end # class NotificationReset
  end # module MySaaS
end # module BlackStack