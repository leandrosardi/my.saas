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

        # --- SMTP pooling / transaction counting (MailerSend: 5 mails per connection) ---
        # Reference: https://github.com/connection-sphere/hub/issues/21
        @@smtp_session = nil
        @@smtp_sent_in_session = 0
        @@smtp_mutex = Mutex.new
        SMTP_MAX_PER_CONNECTION = 5

        # Helper: ensure we have an open session, or open a fresh one
        # Reference: https://github.com/connection-sphere/hub/issues/21
        def self.ensure_smtp_session!
            # called inside @@smtp_mutex.synchronize
            if @@smtp_session.nil? || !@@smtp_session.started? || @@smtp_sent_in_session >= SMTP_MAX_PER_CONNECTION
                # close previous session if exists
                begin
                    if @@smtp_session && @@smtp_session.started?
                        @@smtp_session.finish
                    end
                rescue => e
                    # ignore errors closing old session
                ensure
                    @@smtp_session = nil
                    @@smtp_sent_in_session = 0
                end

                # create and start a fresh Net::SMTP session
                smtp = Net::SMTP.new(@@smtp_url, @@smtp_port)
                smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)

                # if you want to enforce OpenSSL verify mode settings, configure here
                smtp.start(Socket.gethostname, @@smtp_user, @@smtp_password, :plain)
                @@smtp_session = smtp
                @@smtp_sent_in_session = 0
            end
        end

        # Helper: safely finish and clear session
        # Reference: https://github.com/connection-sphere/hub/issues/21
        def self.close_smtp_session!
            begin
                if @@smtp_session && @@smtp_session.started?
                @@smtp_session.finish
                end
            rescue => e
                # ignore close errors
            ensure
                @@smtp_session = nil
                @@smtp_sent_in_session = 0
            end
        end

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
        # delivery using pooled Net::SMTP sessions (respect MailerSend 5-per-connection rule)
        def self.delivery(h)
            receiver_name = h[:receiver_name]
            receiver_email = h[:receiver_email]
            email_subject = h[:subject]
            email_body = h[:body]

            # Build the Mail::Message (headers + html body)
            mail = Mail.new do
                to "#{receiver_email}"
                from "#{BlackStack::Emails::from_name} <#{BlackStack::Emails::from_email}>"
                subject "#{email_subject}"
                html_part do
                    content_type 'text/html; charset=UTF-8'
                    body email_body
                end
            end

            raw_message = mail.to_s

            # Send using pooled Net::SMTP with mutex
            @@smtp_mutex.synchronize do
                begin
                    # ensure session opened (and not exhausted)
                    ensure_smtp_session!

                    # send raw RFC822 message
                    @@smtp_session.send_message(raw_message, @@from_email, receiver_email)

                    # increment counter and close session if reached the per-connection limit
                    @@smtp_sent_in_session += 1
                    if @@smtp_sent_in_session >= SMTP_MAX_PER_CONNECTION
                        # close now to comply with MailerSend "5 mails per connection" rule
                        close_smtp_session!
                    end
                rescue => e
                    # On any SMTP error we must close the session so we start fresh next time.
                    close_smtp_session!

                    # Re-raise so caller can apply its retry/backoff logic.
                    raise e
                end
            end # synchronize
        end


    end # module Emails
end # module BlackStack