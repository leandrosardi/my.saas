# Notification to deliver when a new user signups, and his/her account is created.
module BlackStack
  module MySaaS
    class NotificationYouAdded < BlackStack::MySaaS::Notification
      attr_accessor :added_by # who is the other user who added this user.

      def initialize(i_user, i_added_by)
        super(i_user)
        self.type = 4
        self.added_by = i_added_by
      end
      
      def subject_template
        "#{added_by.name.to_s} Added to his/her #{APP_NAME} account!"
      end

      def body_template()        
        " 
          <p>Dear #{self.user.name.encode_html},</p>

          <p>
          The user <b>#{self.added_by.name.encode_html}</b> (email <a href='mailto:#{self.added_by.email.encode_html}'>#{self.added_by.email.encode_html}</a>) added you to his/her #{APP_NAME.encode_html} account!</p>          
          </p> 
          
          <p>
          Below is the email to access your account:<br/>
          <b>email</b>: #{self.user.email.encode_html}<br/>
          </p> 

          <p>
          Before you can login, you have to reset your password here:<br/>
          <b><a href='#{CS_HOME_WEBSITE.encode_html}/recover'>#{CS_HOME_WEBSITE.encode_html}/recover</a></b><br/>
          </p>

          <p>
          <b><i>PS:</i> Whitelist all emails from #{BlackStack::Emails::sender_email.encode_html}.</b><br/>
          This is important!
          </p>
        "
      end
    end # class NotificationYouAdded
  end # module MySaaS
end # module BlackStack