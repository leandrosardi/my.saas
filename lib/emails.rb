module BlackStack
    module Emails
        # postmark API key
        @@postmark_api_key = nil

        # smtp request sender information
        @@sender_email = nil
        @@from_email = nil
        @@from_name = nil
        
        # smtp request connection information
        @@smtp_url = nil
        @@smtp_port = nil
        @@smtp_user = nil
        @@smtp_password = nil

        # tracking opens, clicks and unsubscribes
        @@tracking_domain_protocol = nil
        @@tracking_domain_tld = nil
        @@tracking_domain_port = nil

        # return the postmark API key
        def self.postmark_api_key
            @@postmark_api_key
        end

        # return the tracking domain
        def self.tracking_domain_protocol
            @@tracking_domain_protocol
        end
        def self.tracking_domain_tld
            @@tracking_domain_tld
        end
        def self.tracking_domain_port
            @@tracking_domain_port
        end
        def self.tracking_url
            "#{@@tracking_domain_protocol}://#{@@tracking_domain_tld}:#{@@tracking_domain_port}"
        end

        # return true if the SMTP server is configured
        # otherwise return false
        def self.is_configured?
            return (
                @@sender_email.to_s.size > 0 &&
                @@from_email.to_s.size > 0 &&
                @@from_name.to_s.size > 0 &&
                @@smtp_url.to_s.size > 0 && 
                @@smtp_port.to_s.size > 0 && 
                @@smtp_user.to_s.size > 0 && 
                @@smtp_password.to_s.size > 0
            )
        end

        # getters and setters
        def self.sender_email
            @@sender_email
        end
        def self.from_email
            @@from_email
        end
        def self.from_name
            @@from_name
        end
        def self.smtp_url
            @@smtp_url
        end
        def self.smtp_port
            @@smtp_port
        end
        def self.smtp_user
            @@smtp_user
        end
        def self.smtp_password
            @@smtp_password
        end
        def self.set(h)
            errors = []

            # validate: h must be a hash
            errors << "h must be a hash" unless h.is_a?(Hash)

            # validate: sender_email is required
            errors << ":sender_email is required" if h[:sender_email].to_s.size==0

            # validate: from_email is required
            errors << ":from_email is required" if h[:from_email].to_s.size==0

            # validate: from_name is required
            errors << ":from_name is required" if h[:from_name].to_s.size==0

            # validate: sender_email is a valid email address
            errors << ":sender_email must be a valid email address" if !h[:sender_email].email?

            # validate: from_email is a valid email address
            errors << ":from_email must be a valid email address" if !h[:from_email].email?

            # validate: from_name is a string
            errors << ":from_name must be a string" if h[:from_name].class!=String

            # validate: smtp_url is required
            errors << ":smtp_url is required" if h[:smtp_url].to_s.size==0

            # validate: smtp_port is required
            errors << ":smtp_port is required" if h[:smtp_port].to_s.size==0

            # validate: smtp_user is required
            errors << ":smtp_user is required" if h[:smtp_user].to_s.size==0

            # validate: smtp_password is required
            errors << ":smtp_password is required" if h[:smtp_password].to_s.size==0

            # validate: smtp_url is a valid url
            errors << ":smtp_url must be a valid url" if !h[:smtp_url].url?

            # validate: tracking_domain_protocol is a string
            errors << ":tracking_domain_protocol must be a valid protocol" if !h[:tracking_domain_protocol].is_a?(String)

            # validate: tracking_domain_tld is not a string
            errors << ":tracking_domain_tld must be a valid tld" if !h[:tracking_domain_tld].is_a?(String)

            # validate: tracking_domain_port is not a number
            errors << ":tracking_domain_port must be a number" if !h[:tracking_domain_port].is_a?(Integer)

            # raise an exception if the email service descriptor doesn't pass all the valdiations.
            raise "Email service descriptor doesn't pass all the valdiations: #{errors.join(', ')}" if errors.size>0

            # map the parameters
            # postmark API key
            @@postmark_api_key = h[:postmark_api_key]
            # smtp request sender information
            @@sender_email = h[:sender_email]
            @@from_email = h[:from_email]
            @@from_name = h[:from_name]
            # smtp request connection information
            @@smtp_url = h[:smtp_url]
            @@smtp_port = h[:smtp_port]
            @@smtp_user = h[:smtp_user]
            @@smtp_password = h[:smtp_password]
            # tracking configuration
            @@tracking_domain_protocol = h[:tracking_domain_protocol]
            @@tracking_domain_tld = h[:tracking_domain_tld]
            @@tracking_domain_port = h[:tracking_domain_port]
        end

        # delivery an email
        def self.delivery(h)
            receiver_name = h[:receiver_name]
            receiver_email = h[:receiver_email] 
            email_subject = h[:subject]
            email_body = h[:body]
            # reply_to_name # use this for tracking re
            # reply_to_email = nil,

            options = { 
                :address              => BlackStack::Emails::smtp_url,
                :port                 => BlackStack::Emails::smtp_port,
                :user_name            => BlackStack::Emails::smtp_user,
                :password             => BlackStack::Emails::smtp_password,
                :authentication       => 'plain',
                :enable_starttls_auto => true, 
                :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
            }
        
            Mail.defaults do
                delivery_method :smtp, options
            end
        
            mail = Mail.new do
                to "#{receiver_email}"
                #message_id the_message_id # use this for
                from "#{BlackStack::Emails::from_name} <#{BlackStack::Emails::from_email}>"
                #reply_to reply_to_email.nil? ? BlackStack::Emails::from_email : reply_to_email
                subject "#{email_subject}"
                html_part do
                    content_type 'text/html; charset=UTF-8'
                    body email_body
                end # html_part      
            end # Mail.new
            
            # deliver the email
            mail.deliver
        end # def smtp        
    end # module Emails
end # module BlackStack