module BlackStack
    module Emails
        class Address < Sequel::Model(:eml_address)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :mta, :class=>:'BlackStack::Emails::Mta', :key=>:id_mta
            one_to_many :addresstags, :class=>:'BlackStack::Emails::AddressTag', :key=>:id_address

            # types
            TYPE_GMAIL = 0
            #TYPE_YAHOO = 1 # pending to develop
            TYPE_HOTMAIL = 2 # pending to develop
            TYPE_CUSTOM = 3 # generic MTA

            def tracking_url
                ret = nil
                if !self.tracking_domain.to_s.empty?
                    ret = "#{BlackStack::Emails.tracking_domain_protocol}://#{self.tracking_domain}:#{BlackStack::Emails.tracking_domain_port}" 
                else
                    ret = BlackStack::Emails.tracking_url
                end
                ret 
            end 

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_sents(dt)
                # stat_sents
                # IX_eml_delivery__id_followup__delivery_success__is_response__id_address
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_sents
                )
                #{BlackStack::Emails::query_sents(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_sents=excluded.stat_sents;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_replies(dt)
                # stat_replies
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_replies
                )
                #{BlackStack::Emails::query_replies(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_replies=excluded.stat_replies;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_positive_replies(dt)
                # stat_positive_replies
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_positive_replies
                )
                #{BlackStack::Emails::query_positive_replies(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_positive_replies=excluded.stat_positive_replies;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_opens(dt)
                # stat_opens (unique)
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_opens
                )
                #{BlackStack::Emails::query_opens(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_opens=excluded.stat_opens;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_unique_opens(dt)
                # stat_opens (unique)
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_unique_opens
                )
                #{BlackStack::Emails::query_opens(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_unique_opens=excluded.stat_unique_opens;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_clicks(dt)
                # stat_clicks
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_clicks
                )
                #{BlackStack::Emails::query_clicks(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_clicks=excluded.stat_clicks;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_unique_clicks(dt)
                # stat_clicks
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_unique_clicks
                )
                #{BlackStack::Emails::query_unique_clicks(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_unique_clicks=excluded.stat_unique_clicks;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_unsubscribes(dt)
                # stat_unsubscribes
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_unsubscribes
                )
                #{BlackStack::Emails::query_unsubscribes(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_unsubscribes=excluded.stat_unsubscribes;
                "   
                DB.execute(q)
            end

            # Update the timeline of this address
            # Reference: https://github.com/leandrosardi/cs/issues/78
            def update_timeline_bounces(dt)
                # stat_bounces
                q = "
                insert into eml_timeline(
                    id, create_time, id_account, id_campaign, id_followup, id_address, 
                    \"year\", \"month\", \"day\", \"hour\", stat_bounces
                )
                #{BlackStack::Emails::query_bounces(
                    from_time=dt,  
                    id_account=nil, 
                    id_campaign=nil, 
                    id_followup=nil, 
                    id_address=self.id
                )}
                on conflict(id_account, id_campaign, id_followup, id_address, \"year\", \"month\", \"day\", \"hour\") 
                do update set stat_bounces=excluded.stat_bounces;
                "   
                DB.execute(q)
            end # def update_timeline

            def update_timeline(dt, l=nil)
                # create dummy log
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # call each update method
                l.logs "Updating sents... "
                update_timeline_sents(dt)
                l.logf 'done'.green

                l.logs "Updating replies... "
                update_timeline_replies(dt)
                l.logf 'done'.green

                l.logs "Updating positives replies... "
                update_timeline_positive_replies(dt)
                l.logf 'done'.green

                l.logs "Updating opens... "
                update_timeline_opens(dt)
                l.logf 'done'.green

                l.logs "Updating unique opens... "
                update_timeline_unique_opens(dt)
                l.logf 'done'.green

                l.logs "Updating clicks... "
                update_timeline_clicks(dt)
                l.logf 'done'.green

                l.logs "Updating unique clicks... "
                update_timeline_unique_clicks(dt)
                l.logf 'done'.green

                l.logs "Updating unsubscribes... "
                update_timeline_unsubscribes(dt)
                l.logf 'done'.green

                l.logs "Updating bounces... "
                update_timeline_bounces(dt)
                l.logf 'done'.green
            end

            # return concatentation of `first_name` and `last_name`
            def name
                "#{self.first_name} #{self.last_name}"
            end

            # return array of Tag object, each one linked to this account thru the table eml_address_tag
            def tags
                self.addresstags.map { |at| at.tag }
            end

            # return array of valid types for an address
            def self.types
                [TYPE_CUSTOM, TYPE_GMAIL]
            end

            # return a descriptive string for a type
            def self.type_name(type)
                case type
                when TYPE_GMAIL
                    'Gmail'
                when TYPE_CUSTOM
                    'Custom'
                else
                    'Unknown'
                end
            end

            # return a hash descriptor of custom configurations for an address type
            def self.type_config(type)
                case type
                    when TYPE_GMAIL
                        {
                            :smtp_address => 'smtp.gmail.com',
                            :smtp_port => 587,
                            :imap_allowed => true,
                            :imap_address => 'imap.gmail.com',
                            :imap_port => 993,
                            :authentication => 'plain',
                            :enable_starttls_auto => true,
                            :openssl_verification_mode => OpenSSL::SSL::VERIFY_NONE,
                            :inbox_label => 'Inbox',
                            :spam_label => '[Gmail]/Spam',
                            :search_all_wildcard => '*',
                        }
                    when TYPE_HOTMAIL
                        {
                            :smtp_address => 'smtp.office365.com',
                            :smtp_port => 587,
                            :imap_allowed => true,
                            :imap_address => 'outlook.office365.com',
                            :imap_port => 993,
                            :authentication => 'login',
                            :enable_starttls_auto => true,
                            :openssl_verification_mode => OpenSSL::SSL::VERIFY_NONE,
                            :inbox_label => 'Inbox',
                            :spam_label => 'Junk',
                            :search_all_wildcard => '',
                        }
                    when TYPE_CUSTOM
                        {
                            :imap_allowed => false,
                        }
                    else
                        {
                            :imap_allowed => false,
                        }
                end
            end # def self.type_config



            # return a descriptive string for the address
            def type_name
                Address.type_name(self.type)
            end

            # validate hash descriptor
            # TODO: move this to a base module, in order to  develop a stub-skeleton/rpc model.
            def self.validate_descriptor(h)
                errors = []
                # validate: h is a hash
                errors << 'h is not a hash' unless h.is_a?(Hash)
                # if h is a hash, then validate the keys
                if h.is_a?(Hash)
                    # validate: id_user is mandatory
                    errors << 'id_user is mandatory' unless h[:id_user] 
                    # validate: id_mta is mandatory
                    errors << 'id_mta is mandatory' unless h[:id_mta]
                    # validate: type is mandatory
                    errors << 'type is mandatory' unless h[:type]
                    # validate: first_name is mandatory
                    errors << 'first_name is mandatory' unless h[:first_name]
                    # validate: last_name is mandatory
                    errors << 'last_name is mandatory' unless h[:last_name]
                    # validate: address is mandatory
                    errors << 'address is mandatory' unless h[:address]
                    # validate: password is mandatory
                    errors << 'password is mandatory' unless h[:password] || h[:type].to_s == BlackStack::Emails::Address::TYPE_CUSTOM.to_s
                    # validate: shared is mandatory
                    #errors << 'shared is mandatory' unless h[:shared]
                    # validate: max_deliveries_per_day is mandatory
                    #errors << 'max_deliveries_per_day is mandatory' unless h[:max_deliveries_per_day]
                    # validate: enabled is mandatory
                    #errors << 'enabled is mandatory' unless h[:enabled]

                    # validate: id_user is an uuid
                    errors << 'id_user is not an uuid' if h[:id_user] && !h[:id_user].to_s.guid?
                    # validate: user exists
                    errors << 'user does not exists' if h[:id_user] && BlackStack::MySaaS::User.where(:id=>h[:id_user]).first.nil?

                    # validate: id_mta is an uuid
                    errors << 'id_mta is not an uuid' if h[:id_mta] && !h[:id_mta].to_s.guid?
                    # validate: mta exists and it is belonging the user's account
                    errors << 'mta does not exists in the account of the user' if h[:id_mta] && DB["
                        SELECT * 
                        FROM eml_mta m
                        JOIN \"user\" u ON (u.id = m.id_user AND u.id_account = '#{BlackStack::MySaaS::User.where(:id=>h[:id_user]).first.id_account}')
                    "].first.nil?

                    # validate: if type exists it is a valid value
                    errors << "type is not a valid value (#{BlackStack::Emails::Address.types.join(', ')})" if h[:type] && !BlackStack::Emails::Address.types.include?(h[:type].to_i)
                    # validate: if address exists it is a valid email address
                    errors << 'address is not a valid email address' if h[:address] && !h[:address].to_s.email?
                    # validate: if password exists it is a string
                    errors << 'password is not a string' if h[:password] && !h[:password].is_a?(String)
                    # validate: if shared exists it is a boolean
                    errors << 'shared is not a boolean' if h[:shared] && !h[:shared].is_a?(TrueClass) && !h[:shared].is_a?(FalseClass)
                    # validate: if max_deliveries_per_day exists it is a number
                    errors << 'max_deliveries_per_day is not a number' if h[:max_deliveries_per_day] && !h[:max_deliveries_per_day].to_s =~ /^\d+$/
                    # validate: if enabled exists it is a boolean
                    errors << 'enabled is not a boolean' if h[:enabled] && !h[:enabled].is_a?(TrueClass) && !h[:enabled].is_a?(FalseClass)
                    # return
                    errors
                end # if h.is_a?(Hash)
            end # def self.validate

            # create a new object from a hash descriptor
            def initialize(h)
                # create Sequel object
                super()
                # validate descriptor
                errors = BlackStack::Emails::Address.validate_descriptor(h)
                raise errors.join(', ') unless errors.empty?
                # map attributes
                self.id = guid
                self.create_time = now
                self.id_user = h[:id_user]
                self.id_mta = h[:id_mta]
                self.type = h[:type].to_i
                self.first_name = h[:first_name]
                self.last_name = h[:last_name]
                self.address = h[:address]
                self.password = h[:password]
                self.shared = h[:shared] || false
                self.max_deliveries_per_day = h[:max_deliveries_per_day] || 50
                self.enabled = h[:enabled] || false
                self.max_deliveries_per_day = h[:max_deliveries_per_day] || 10
                self.delivery_interval_min_minutes = h[:delivery_interval_min_minutes] || 20
                self.delivery_interval_max_minutes = h[:delivery_interval_max_minutes] || 30
            end

            # update object from a hash descriptor
            def to_hash
                {
                    :id => self.id,
                    :create_time => self.create_time,
                    :id_user => self.id_user,
                    :id_mta => self.id_mta,
                    :type => self.type,
                    :first_name => self.first_name,
                    :last_name => self.last_name,
                    :address => self.address,
                    :password => self.password,
                    :shared => self.shared,
                    :max_deliveries_per_day => self.max_deliveries_per_day,
                    :enabled => self.enabled
                }
            end

            # return an Address object belonging the account of the user, with the same address and id_mta
            def self.load(h)
                u = BlackStack::Emails::User.where(:id=>h[:id_user]).first
                row = DB["
                    SELECT a.id 
                    FROM eml_address a
                    JOIN \"user\" u ON ( u.id=a.id_user AND u.id_account='#{u.id_account}' )
                    WHERE a.address='#{h[:address]}' 
                    AND a.id_mta='#{h[:id_mta]}' 
                "].first
                return nil if row.nil?
                return BlackStack::Emails::Address.where(:id=>row[:id]).first
            end

            # return true if the user's account already has an MTA record with these settings
            def self.exists?(h)
                !BlackStack::Emails::Address.load(h).nil?
            end

            # return true if the user's account already has an MTA record with these settings
            def exists?
                !BlackStack::Emails::Address.exists?(self.to_hash).nil?
            end

            # test the the login to the imap server
            # raise an exception if the login fails
            def test
                imap = Net::IMAP.new(self.mta.imap_address, self.mta.imap_port, true)
                res = imap.login(self.address, self.password)
                raise res.name unless res.name == "OK"
                imap.logout
            end

            # send email.
            # return the message_id of the delivered email.
            #
            # this is a general purpose method to send email.
            # end user should not call this method.
            #
            def send_email(to_email, to_name, subject, body, from_name, reply_to=nil, track_opens=false, track_clicks=false, id_delivery=nil, text_only=false)
                mta = self.mta

                options = { 
                    :address                => mta.smtp_address,
                    :port                   => mta.smtp_port,
                    :user_name              => self.mta.smtp_username.to_s.empty? ? self.address : self.mta.smtp_username,
                    :password               => self.mta.smtp_password.to_s.empty? ? self.password : self.mta.smtp_password,
                    :authentication         => 'plain', #mta.authentication,
                    :enable_starttls_auto   => true, #mta.enable_starttls_auto,
                    :openssl_verify_mode    => OpenSSL::SSL::VERIFY_NONE #mta.openssl_verify_mode
                }
                
                Mail.defaults do
                    delivery_method :smtp, options
                end

                # build the plain-text body
                doc = Nokogiri::HTML(body)
                doc.search('p,div,br').each{ |e| e.after "\n" }

                addr = self
                mail = Mail.new do
                    from "#{from_name} <#{addr.address}>"
                    to "#{to_name} <#{to_email}>"
                    
                    reply_to "#{reply_to}" if !reply_to.nil?
                    
                    subject "#{subject}"
                    
                    # plain text email
                    body "#{text_only ? doc.text : body}"

                    if !text_only
                        html_part do
                            content_type 'text/html; charset=UTF-8'
                            body "#{body}"
                        end                
                    end

                    text_part do
                        body doc.text
                    end

                end # Mail.new

                # deliver the email
                message = mail.deliver
                
                # record the message_id in the database, in order to track the conversation thread
                return message.message_id
            end # send

            # recevive all same the parameters than `send_email` but into a hash.
            # validate the value of each parameters.
            # raise exception with all the errors found in the parameters.
            # if there is no errors, then call `send_email` with the parameters. 
            def send(h)
                err = []
                # validate: h is a hash
                err << 'h is not a hash' unless h.is_a?(Hash)
                # validate: to_email is required
                err << 'to_email is required' unless h[:to_email]
                # validate: to_name is required
                err << 'to_name is required' unless h[:to_name]
                # validate: subject is required
                err << 'subject is required' unless h[:subject]
                # validate: body is required
                err << 'body is required' unless h[:body]
                # validate: from_name is required
                err << 'from_name is required' unless h[:from_name]
                # validate: reply_to is required
                #err << 'reply_to is required' unless h[:reply_to]
                # validate: to is a string and it is a valid email address
                err << 'to is not a string' if !h[:to].nil? && !h[:to].is_a?(String)
                err << 'to is not a valid email address' if !h[:to].nil? && !h[:to].to_s.email?
                # validate: subject is a string
                err << 'subject is not a string' if !h[:subject].nil? && !h[:subject].is_a?(String)
                # validate: body is a string
                err << 'body is not a string' if !h[:body].nil? && !h[:body].is_a?(String)
                # validate: from_name is a string
                err << 'from_name is not a string' if !h[:from_name].nil? && !h[:from_name].is_a?(String)
                # validate: reply_to is a string and it is a valid email address
                err << 'reply_to is not a string' if !h[:reply_to].to_s.empty? && !h[:reply_to].is_a?(String)
                err << 'reply_to is not a valid email address' if !h[:reply_to].to_s.empty? && !h[:reply_to].to_s.email?
                # validate: text_only is mandatory and it is a boolean
                err << 'text_only is not a boolean' if !h[:text_only].nil? && !h[:text_only].is_a?(TrueClass) && !h[:text_only].is_a?(FalseClass)
                # raise exception if any error
                raise err.join("\n") unless err.empty?
                # send email & return the message_id
                return send_email(
                    h[:to_email], 
                    h[:to_name], 
                    h[:subject], 
                    h[:body], 
                    h[:from_name], 
                    h[:reply_to],
                    false, # track_opens
                    false, # track_clicks
                    nil, # id_delivery
                    h[:text_only]
                )
            end

            # send a test email to the logged in user
            def send_test(followup, lead, email)
                self.send({
                    :to_email => email,
                    :to_name => lead.name, 
                    :subject => '[Test] ' + followup.merged_subject(lead).spin, 
                    :body => followup.merged_body(lead).spin, 
                    :from_name => "#{self.first_name} #{self.last_name}", 
                    #:reply_to => campaign.reply_to,
                    :text_only => (followup.type == BlackStack::Emails::Followup::TYPE_TEXT)
                })
            end

            # send a test email to the logged in user
            def send_deliverability_check(followup, lead, email, body_code=nil, subject_code=nil)
                subject = followup.merged_subject(lead).spin
                subject += " - #{subject_code}" if !subject_code.nil?

                body = followup.merged_body(lead).spin
                body += "\n\n\n\n#{body_code}" if !body_code.nil?
                
                self.send({
                    :to_email => email,
                    :to_name => lead.name, 
                    :subject => subject, 
                    :body => body, 
                    :from_name => "#{self.first_name} #{self.last_name}", 
                    #:reply_to => campaign.reply_to,
                    :text_only => (followup.type == BlackStack::Emails::Followup::TYPE_TEXT)
                })
            end

            # connect the address via IMAP.
            # find the new incoming emails, using the last ID processed.
            # for each email, if it is a reply to a previous email sent by the system, then insert it in the delivery table.
            # update the last id processed for this address.
            #
            # This method is for internal use only.
            # It should not be called by the end user.
            # 
            def receive(l=nil, limit=1000)
                addr = self
#addr.imap_inbox_last_id = nil
#addr.imap_spam_last_id = nil
                mta = self.mta
                sources = [
                    {:folder=>mta.inbox_label, :track_field=>'imap_inbox_last_id'}, 
                    {:folder=>mta.spam_label, :track_field=>'imap_spam_last_id'},
                ]

                # create dummy log
                l = BlackStack::DummyLogger.new(nil) if l.nil?

                # connecting imap 
                l.logs "Connecting IMAP... "
                imap = Net::IMAP.new(mta.imap_address, mta.imap_port, true)
                conn = imap.login(
                    addr.mta.imap_username.to_s.empty? ? addr.address : addr.mta.imap_username , 
                    addr.mta.imap_password.to_s.empty? ? addr.password : addr.mta.imap_password
                )
                l.logf "done (#{conn.name})"
        
                sources.each { |source|
                    folder = source[:folder]
                    track_field = source[:track_field]
#binding.pry
                    l.logs "Choosing mailbox #{folder}... "

                        l.logs "Examine folder... "
                        res = imap.examine(folder)
                        l.logf "done (#{res.name})"
                
                        # Gettin latest `limit` messages received, in descendent order (newer first), 
                        # in order to stop when I find the latest procesed before.
                        l.logs "Getting latest #{limit.to_s} messages... "
                        ids = imap.search(["SUBJECT", mta.search_all_wildcard]).reverse[0..limit]
                        l.logf "done (#{ids.size.to_s} messages)"
                        
                        # iterate the messages
                        first_message_id = nil
                        ids.each { |id|
                            l.logs "Processing message #{id.to_s}... "
                            # getting the envelope
                            envelope = imap.fetch(id, "ENVELOPE")[0].attr["ENVELOPE"]
                            from_email = envelope.from[0].mailbox.to_s + '@' + envelope.from[0].host.to_s

                            # TODO: develop a normalization function for mail.message_id
                            message_id = envelope.message_id.to_s.gsub(/^</, '').gsub(/>$/, '')
                            first_message_id = message_id if first_message_id.nil?
                            
                            # check if this message_id is is the latest processed
                            if message_id == addr[track_field.to_sym]
                                l.logf "done with all new messages"
                                break
#                            else
elsif envelope.subject =~ /[0-9A-Z]{7}\-[0-9A-Z]{7}/i
    l.logf "Instantly warming email".red
else                                
                                # check if it is a reply to a previous email sent by the system
                                d = BlackStack::Emails::Delivery.previous(self, imap, id, envelope)
                                if d.nil?
                                    # problem: the lead replied from another email address. 
                                    # There is no solution. it is not possible to track the conversation. 
                                    #
                                    # solution: register the message as a new conversation.
                                    #
#                                    if !addr.accept_all
#                                        l.logf "ignored".red # not a reply to a previous email sent by the system
#                                    else
#binding.pry #if from_email=='apicturesquememory@gmail.com'
                                        BlackStack::Emails::Delivery.register_new_conversation(self, imap, id, envelope)
                                        l.logf "new message (#{id} - #{from_email} - #{envelope.subject})".green # insert such a reply in database 
#                                    end
                                else
#binding.pry
                                    d.insert_reply(imap, id, envelope)
                                    l.logf "new response (#{id} - #{from_email} - #{envelope.subject})".green # insert such a reply in database 
                                end
                            end
                            
                            # TODO: ingest ALL the inbox anyway, in order to gather information about our users
                            # TODO: ingest ALL the sent messages anyway, in order to gather information about our users
                            # TODO: track the automated warming up emails
                        }

                        # update the last id processed
                        l.logs "Updating #{track_field}... "
                        DB.execute("update eml_address set #{track_field} = '#{first_message_id.to_s}' where id='#{addr.id.to_guid}'") unless first_message_id.nil?
                        l.done
                        
                    l.done

                } # end folders.each

                # disconnect
                l.logs "Disconnecting IMAP... "
                res = imap.logout
                l.logf "done (#{res.name})"
            end # end receive

            # DEPRECATED
            # return: daily_quota - emails deliveried in last 24 hours
            def daily_left
                # emails deliveried in last 24 hours
                i = DB["
                    select count(d.id) as n
                    from eml_delivery d
                    where coalesce(d.delivery_end_time, '2000-01-01') >= CAST('#{now()}' AS TIMESTAMP) - INTERVAL '1 day'
                    and d.delivery_success=true
                    and d.is_response=false
                "].first[:n]
                # return: daily_quota - emails deliveried in last 24 hours - emails pending to be delivered 
                self.max_deliveries_per_day - i
            end

            # receives: array of IDs of eml_address objects
            # return: hash with the daily_quota-delivered + last_delivery_minutes_ago, of each address.
            def self.daily_left_for_delivery(ids)
                q = "
                    select 
                        a.id, --a.address, a.max_deliveries_per_day, 
                        --max(coalesce(d.delivery_end_time, '2000-01-01')) as last_delivery_end_time,
                        cast(cast('#{now}' as timestamp) - max(coalesce(d.delivery_end_time, '2000-01-01')) as int)/60 as last_delivery_minutes_ago,
                        a.max_deliveries_per_day - (
                            -- emails deliveried in last 24 hours
                            select count(d.id) as n
                            from eml_delivery d
                            where coalesce(d.delivery_end_time, '2000-01-01') >= CAST('#{now()}' AS TIMESTAMP) - INTERVAL '1 day'
                            and d.delivery_success=true
                            and d.is_response=false
                            and d.id_address = a.id
                        ) as daily_left
                    --select count(*) 
                    from eml_address a
                    left join eml_delivery d on (
                        a.id=d.id_address and 
                        d.is_response=false and 
                        d.delivery_end_time is not null and 
                        d.delivery_success=true
                    )
                    where a.id in ('#{ids.join("','")}')
                    group by a.id
                "
                DB[q].all.map { |r| [r[:id], {:daily_left=>r[:daily_left], :last_delivery_minutes_ago=>r[:last_delivery_minutes_ago].to_i}] }.to_h
            end

            # receives: array of IDs of eml_address objects
            # return: hash with the daily_quota-delivered-pending of each address.
            def self.daily_left_for_planning(ids)
                q = "
                    select 
                        a.id, --a.address, a.max_deliveries_per_day, 
                        a.max_deliveries_per_day - (
                            -- emails deliveried in last 24 hours
                            select count(d.id) as n
                            from eml_delivery d
                            where coalesce(d.delivery_end_time, '2000-01-01') >= CAST('#{now()}' AS TIMESTAMP) - INTERVAL '1 day'
                            and d.delivery_success=true
                            and d.is_response=false
                            and d.id_address = a.id
                        ) - (
                            -- emails pending to be delivered
                            select count(d.id) as n
                            from eml_delivery d
                            where d.delivery_end_time is null
                            and coalesce(d.is_response,false)=false
                            and d.id_address = a.id
                        ) as daily_left
                    --select count(*) 
                    from eml_address a
                    where a.id in ('#{ids.join("','")}')
                "
                DB[q].all.map { |r| [r[:id], r[:daily_left]] }.to_h
            end


            # return array of IDs of addresses available for sending an email right now
            # n: number of IDs to return. If n == -1, there is no limit. 
            # shared: boolean. If I am looking for shared addresses or not.
            # id_account: if I am looking for addresses belonging an account. If nil, I am looking for addresses belonging to any account.
            # id_campaign: if I am looking for addreses belinging a campaign as per their tags. If nil, I am looking for addresses belonging to any campaign.
            #
            # if `id_campaign` is not nil, then `id_account` must be not nil.
            # 
            def self.get_ids_of_available_addresses(n=-1, shared=true, id_account=nil, id_campaign=nil)
                # if `id_campaign` is not nil, then `id_account` must be not nil.
                raise "id_account must be not nil if id_campaign is not nil" if !id_campaign.nil? && id_account.nil?
                
                # filter addresses beloning an account
                a = ''
                a = "
                    join \"user\" u on (u.id=a.id_user and u.id_account='#{id_account}')
                " unless id_account.nil?
                
                # filter addresses belonging a campaign
                b = ''
                if id_campaign
                    o = BlackStack::Emails::Outreach.where(:id_campaign => id_campaign).first
                    if o
                        # if the campaign has tags defined
                        b = "
                            join eml_address_tag eat on a.id=eat.id_address 
                            join eml_outreach eo on (
                                eo.id_tag = eat.id_tag and 
                                eo.id_campaign = '#{id_campaign}'
                            )            
                        " 
                    else
                        # if the campaign has not tags defined
                    end
                end

                # if I am looking for shared addresses, then I apply filter `shared=true`.
                # If I am not looking for shared addresses, it may be shared or not. 
                c = ''
                c = "and a.shared=true" if shared 
                # 
                d = ''
=begin
                if respect_quotas
                    d = "
                        -- remove addresses with more than `self.max_deliveries_per_day` pending deliveries
                        except
                        select a.id
                        from eml_address a
                        join eml_delivery d on (
                            a.id=d.id_address and
                            d.is_response = false and
                            d.delivery_end_time is null and
                            d.delivery_end_time > cast('#{now()}' as timestamp) - interval '24 hours'
                        ) 
                        group by a.id, a.max_deliveries_per_day
                        having count(d.id) >= a.max_deliveries_per_day
                        -- remove addresses who sent more than `self.max_deliveries_per_day` in the last 24 hours
                        except
                        select a.id
                        from eml_address a
                        join eml_delivery d on (
                            a.id=d.id_address and
                            d.is_response = false and
                            d.delivery_end_time is not null and
                            d.delivery_end_time > cast('#{now()}' as timestamp) - interval '24 hours'
                        ) 
                        group by a.id, a.max_deliveries_per_day
                        having count(d.id) >= a.max_deliveries_per_day
                        -- if the last delivery happened `self.delivery_interval_min_minutes` ago.
                        except
                        select a.id
                        from eml_address a
                        join eml_delivery d on (
                            a.id=d.id_address and
                            d.is_response = false and
                            d.delivery_end_time is not null and
                            d.delivery_end_time > cast('#{now()}' as timestamp) - interval '1 minute' * (a.delivery_interval_min_minutes + cast(random() * cast(a.delivery_interval_max_minutes-a.delivery_interval_min_minutes as float) as integer))
                        ) 
                        group by a.id, a.max_deliveries_per_day
                        having count(d.id) >= 1
                    "
                end
=end
                # build the query
                q = "
                select v.id 
                from (
                    select a.id
                    from eml_address a
                    #{a}
                    #{b}
                    where a.enabled = true 
                    and a.delete_time is null
                    #{c}
                    #{d}
                ) as v  
                "

                # sort randonly
                q += "
                    order by random()
                "

                if n > 0
                    q += "
                        limit #{n.to_s}
                    "
                end
                # return
                DB[q].all.map{|x| x[:id]}
            end

            # return array of addresses available for sending an email right now
            def self.get_available_addresses(n=-1, shared=true, id_account=nil, id_campaign=nil)
                ret = []
                BlackStack::Emails::Address.get_ids_of_available_addresses(n, shared, id_account, id_campaign).each { |id|
                    ret << BlackStack::Emails::Address.where(:id=>id).first
                    GC.start
                    DB.disconnect
                }
                ret
            end

        end # class Address

=begin
        # removed becuase of the issue https://github.com/ConnectionSphere/emails/issues/31
        class GMail < BlackStack::Emails::Address
            # authentication token file
            def token
                token = "#{self.user.account.storage_sub_folder('emails.google.tokens')}/#{id}.yaml".freeze
            end # def token
            
            # to access the gmail account, we need to use the gmail api's credentials
            def credentials
                oob_uri = BlackStack::Emails::GoogleConfig::oob_uri
                app_name = BlackStack::Emails::GoogleConfig::app_name
                google_api_certificate = BlackStack::Emails::GoogleConfig::google_api_certificate
                scope = BlackStack::Emails::GoogleConfig::scope 
            
                client_id = Google::Auth::ClientId.from_file google_api_certificate
                token_store = Google::Auth::Stores::FileTokenStore.new file: self.token
                authorizer = Google::Auth::UserAuthorizer.new client_id, scope, token_store
                user_id = 'default'
                ret = authorizer.get_credentials user_id
                raise "Address credentials not found" if ret.nil?
                ret
            end

            # get gmail service
            def service
                require "google/apis/gmail_v1"
                require "googleauth"
                require "googleauth/stores/file_token_store"
            
                app_name = BlackStack::Emails::GoogleConfig::app_name
                service = Google::Apis::GmailV1::GmailService.new
                service.client_options.application_name = app_name
                service.authorization = self.credentials
                service
            end # def service

            # send email.
            # this is a general purpose method to send email.
            # this should not call this method.
            def send_email(to, subject, body, from_name, reply_to, track_opens=false, track_clicks=false, id_delivery=nil)
                user_id = "me"
                message = Mail.new(body)
                message.to = to
                message.from = "#{from_name} <#{self.address}>"
                message.reply_to = reply_to
                message.subject = subject
                message.text_part = body
                message.html_part = body
                self.service.send_user_message(user_id, upload_source: StringIO.new(message.to_s), content_type: 'message/rfc822')                
            end # send
        end # class GMail
=end
    end # Emails
end # BlackStack