# Notification to deliver when a new user signups, and his/her account is created.
module BlackStack
  module MySaaS
    class NotificationWelcome < BlackStack::MySaaS::Notification
      def initialize(i_user)
        super(i_user)
        self.type = 1
      end
      
      def subject_template
        "Welcome to #{APP_NAME}! - 3 Bonuses for You!"
      end

      def body_template()        
        " 
          <p>Dear #{self.user.name.encode_html},</p>

          <p>Welcome to <b>#{APP_NAME.encode_html}</b>!</p>          

          <p>Thank you so much for joining us!</p>

          <p>I am very excited to have you on board.</p> 
          
          <p><b>Now You have access to a Full-Toolkit for running Cold Email Campaigns.</b></p>

          <p>As a way to say 'Thank You', I have 3 special bonuses for You!</p>

          <p><b>Bonus #1: Free Leads + Built-For-You Email Outreach System.</b></p>

          <p>
          You have received 300 credits for download B2B Leads, with Emails & Phone Number.... <br/>
          Plus, other 300 credits for sending cold emails to them from our built-for-you email outreach system.<br/>
          <br/> 
          Really! It's Free!<br/>
          <br/>
          Just go here to get started: <a href='#{CS_HOME_WEBSITE}/new'>#{CS_HOME_WEBSITE}/new</a>
          </p>

          <p><b>Bonus #2: 50% OFF + 15-Day Trial Our Premium Plan.</b></p>

          <p>
          You can upgrade to our Premium plan and get it <b>50% OFF Forever</b>, plus a <b>15-Day Trial</b>!<br/>
          Just go here to grab the offer: <a href='#{CS_HOME_WEBSITE}/offer'>#{CS_HOME_WEBSITE}/offer</a><br/>
          <i>(Hurry Up! It is for limited time only!)</i>
          </p>

          <p><b>Bonus #3: Free Cold Emails Masterclass.</b></p>

          <p>
          Upgrading to our <a href='#{CS_HOME_WEBSITE}/offer'>Premium Plan</a> you not only get 50% OFF Forever, but you also get free access to our <a href='#{CS_HOME_WEBSITE}/seminars/pub/leads-generation/cold-emails-seminar'>Prospecting Masterclass</a> where we share: <b>how to use our proven scripts to generate leads at high conversion.</b><br/>
          </p>

          <p><b>Also,</b></p>

          <p>
          <b>Whitelist all emails from #{BlackStack::Emails::sender_email.encode_html}.</b><br/>
          This is important!<br/>
          We use to develop new features and release free seminars very often.
          </p>

          <p><b>Login Details:</b></p>

          <p>
          Here are your credentials to access your account:<br/>
          <b>email</b>: #{self.user.email.encode_html}<br/>
          <b>password</b>: #{self.user.default_password.encode_html}<br/>
          <br/>
          I recommend you to setup a new password here: <a href='#{CS_HOME_WEBSITE}/settings/password'>#{CS_HOME_WEBSITE}/settings/password</a><br/>
          <br/>
          You can always login here: <a href='#{CS_HOME_WEBSITE}/login'>#{CS_HOME_WEBSITE}/login</a>.<br/>
          <br/>
          If you don't rememer your password at any moment, you can reset it here: <a href='#{CS_HOME_WEBSITE}/recover'>#{CS_HOME_WEBSITE}/recover</a>.
          </p> 
        "
      end
    end # class NotificationWelcome
  end # module MySaaS
end # module BlackStack