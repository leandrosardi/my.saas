module BlackStack
    module Emails
        class Delivery < Sequel::Model(:eml_delivery)
            many_to_one :lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead
            many_to_one :user, :class=>:'BlackStack::Emails::User', :key=>:id_user
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address
            many_to_one :followup, :class=>:'BlackStack::Emails::Followup', :key=>:id_followup

            one_to_many :opens, :class=>:'BlackStack::Emails::Open', :key=>:id_delivery
            one_to_many :clicks, :class=>:'BlackStack::Emails::Click', :key=>:id_delivery
            one_to_many :unsubscribes, :class=>:'BlackStack::Emails::Unsubscribe', :key=>:id_delivery

            #LOG_TYPES = ['pending', 'failed', 'sent', 'open', 'click', 'unsubscribe', 'bounce', 'complaint', 'reply']
            LOG_TYPES = ['pending', 'failed', 'sent', 'open', 'click', 'unsubscribe', 'reply']

            def reset_push_to_micro_emails_timeline
                self.micro_emails_timeline_push_start_time = nil
                self.micro_emails_timeline_push_end_time = nil
                self.save
            end

            def reset_push_to_micro_emails_timeline
                self.micro_emails_timeline_push_reservation_id = nil
                self.micro_emails_timeline_push_reservation_time = nil
                self.micro_emails_timeline_push_reservation_times = nil
                self.micro_emails_timeline_push_start_time = nil
                self.micro_emails_timeline_push_end_time = nil
                self.micro_emails_timeline_push_success = nil
                self.micro_emails_timeline_push_error_description = nil
                self.save
            end

            def push_to_micro_emails_timeline(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                d = self

                l.logs "Get account... "
                a = d.followup.user.account
                l.logf a.id.blue
            
                l.logs "Assign micro-service... "
                n = BlackStack::Workmesh.assigned_node(a, :'micro.emails.timeline')
                n = BlackStack::Workmesh.assign(a, :'micro.emails.timeline') if n.nil?
                l.logf n.name.blue
            
                l.logs "Push delivery to micro-service... "
                BlackStack::Workmesh.service(:'micro.emails.timeline').protocol('push_delivery').push(d, n)
                l.logf "done".green

                # sort by create_time, because micro-service need to receive them sorted in order to track unique-opens correctly
                l.logs "Push delivery opens... "
                self.opens.sort_by { |o| o.create_time }.each { |o|
                    o.push_to_micro_emails_timeline(l)
                    l.log ''
                }
                l.logf "done".green

                # sort by create_time, because micro-service need to receive them sorted in order to track unique-clicks correctly
                l.logs "Push delivery clicks... "
                self.clicks.sort_by { |o| o.create_time }.each { |o|
                    o.push_to_micro_emails_timeline(l)
                    l.log ''
                }
                l.logf "done".green

                l.logs "Push delivery unsubscribes... "
                self.unsubscribes.sort_by { |o| o.create_time }.each { |o|
                    o.push_to_micro_emails_timeline(l)
                    l.log ''
                }
                l.logf "done".green
            end

            # return either html version of the body, assuming it is the full mime content.
            # 
            # reference: https://stackoverflow.com/questions/4868205/rails-mail-getting-the-body-as-plain-text
            #
            # TODO: Also, remove open tracking pixel
            def simplified_body
                ret = nil
                # get the HTML body
                m = Mail.new(self.body.to_s)
                if m.html_part
                    ret = m.html_part.body.decoded
                elsif m.body
                    ret = m.body.decoded
                end
                # reference: https://github.com/ConnectionSphere/emails/issues/121
                doc = Nokogiri::HTML(ret)
                doc.css('style').remove # remove all css
                doc.css('script').remove # remove all javascript
                doc.xpath('//@style').remove # remove all inline css - https://stackoverflow.com/questions/6096327/strip-style-attributes-with-nokogiri
                # remove tracking pixel
                # reference: https://github.com/ConnectionSphere/emails/issues/99
                doc.css('img').each do |img|
                    if img['src'] && img['src'].include?('api1.0/emails/open.json')
                        img.remove
                    end
                end
                # get the processed body
                body = doc.at('body')
                if body
                    return body.inner_html
                else
                    return doc.to_s
                end
            end
            
            # return a hash descriptor of this object
            def to_hash(include_content=true)
                # build the hash
                ret = {
                    'id' => self.id,
                    'id_campaign' => self.followup.id_campaign,
                    'id_followup' => self.id_followup,
                    'id_address' => self.id_address,
                    'id_lead' => self.id_lead,
                    'create_time' => self.create_time,
                    
                    'delivery_start_time' => self.delivery_start_time,
                    'delivery_end_time' => self.delivery_end_time,
                    'delivery_success' => self.delivery_success,
                    'delivery_error_description' => self.delivery_error_description,    

                    'id_conversation' => self.id_conversation,
                    'is_response' => self.is_response,
                    'is_single' => self.is_single,
                    'id_user' => self.id_user,

                    'is_bounce' => self.is_bounce,
                    'bounce_reason' => self.bounce_reason,
                    'bounce_diagnosticcode' => self.bounce_diagnosticcode,
                
                    'is_positive' => self.is_positive,
                    'positive_type' => self.positive_type,
                    'positive_value' => self.positive_value,
                
                    'email' => self.email,
                    'subject' => self.subject,
    
                    'message_id' => self.message_id,

                    'address' => self.address.to_hash,
                    'lead' => self.lead.to_hash,
                    'unsubscribed' => BlackStack::Emails::Unsubscribe.where(:id_delivery=>self.id).count > 0,
                    'export_filename' => self.id_followup ? self.followup.campaign.export.filename : nil,
                }

                if include_content
                    ret['body'] = self.body
                    ret['simplified_body'] = self.simplified_body
                end

                ret
            end
=begin
# this method is not necessary, because deliveries are not being created via API
            # update object from a hash descriptor
            def parse(h)
                self.id = h['id']
                self.id_followup = h['id_followup']
                self.id_address = h['id_address']
                self.id_lead = h['id_lead']
                self.create_time = h['create_time']
                self.delivery_start_time = h['delivery_start_time']
                self.delivery_end_time = h['delivery_end_time']
                self.delivery_success = h['delivery_success']
                self.delivery_error_description = h['delivery_error_description']
                self.id_conversation = h['id_conversation']
                self.is_response = h['is_response']
                self.is_single = h['is_single']
                self.id_user = h['id_user']
                self.is_bounce = h['is_bounce']
                self.bounce_reason = h['bounce_reason']
                self.bounce_diagnosticcode = h['bounce_diagnosticcode']
                self.is_positive = h['is_positive']
                self.positive_type = h['positive_type']
                self.positive_value = h['positive_value']
                self.email = h['email']
                self.subject = h['subject']
                self.body = h['body']
                self.simplified_body = h['simplified_body']
                self.message_id = h['message_id']
            end
=end
            def self.log_type_color(type)
                raise "Invalid log type #{type}." unless LOG_TYPES.include?(type)
                ret = nil
                case type
                    when 'pending'
                        ret = 'gray'
                    when 'failed'
                        ret = 'red'
                    when 'sent'
                        ret = 'green'
                    when 'open'
                        ret = 'blue'
                    when 'click'
                        ret = 'pink'
                    when 'unsubscribe'
                        ret = 'orange'
                    when 'bounce'
                        ret = 'red'
                    when 'complaint'
                        ret = 'red'
                    when 'reply'
                        ret = 'purple'
                end
                ret
            end

            # track en event in the table eml_log
            def track(type, url=nil, error_description=nil)
                raise "Invalid log type #{type}." unless LOG_TYPES.include?(type)
                DB.execute("
                    INSERT INTO eml_log (
                        id,
                        create_time,
                        \"type\",
                        \"color\",
                        id_lead,
                        id_delivery, 
                        id_followup, 
                        id_campaign,
                        lead_name,
                        campaign_name,
                        planning_time,
                        \"url\",
                        planning_id_address,
                        \"address\",
                        \"subject\",
                        \"body\",
                        error_description,
                        id_account,
                        lead_email
                    ) VALUES (
                        '#{guid}',
                        '#{now}',
                        '#{type.to_sql}',
                        '#{self.class.log_type_color(type)}',
                        '#{self.id_lead}',
                        '#{self.id}',
                        '#{self.id_followup}',
                        '#{self.followup.id_campaign}',
                        '#{self.lead.name.to_sql}',
                        '#{self.followup.campaign.name.to_sql}',
                        '#{self.create_time}',
                        #{url.nil? ? "NULL" : "'#{url.to_sql}'"},
                        '#{self.address.id}',
                        '#{self.address.address.to_sql}',
                        '#{self.subject.to_sql}',
                        '#{self.body.to_sql}',
                        #{error_description.nil? ? "NULL" : "'#{error_description.to_sql}'"},
                        '#{self.followup.campaign.user.id_account}',
                        '#{self.email.to_sql}'
                    )
                ")
            end

            # update the delivery flags
            def start_delivery()
                DB.execute("UPDATE eml_delivery SET delivery_start_time='#{now}', delivery_end_time=null, delivery_success=null, delivery_error_description=null WHERE id='#{self.id}'")
            end

            # update the delivery flags
            def end_delivery(error=nil, message_id=nil)
                DB.execute("UPDATE eml_delivery SET delivery_end_time='#{now}', delivery_success=#{error.nil? ? 'true' : 'false'}, delivery_error_description=#{error.nil? ? "NULL" : "'#{error.to_sql}'"}, message_id=#{message_id.nil? ? "NULL" : "'#{message_id.to_sql}'"} WHERE id='#{self.id}'")
            end

            # send email
            def deliver(l=nil)
                #l = BlackStack::Logger::DummyLogger.new(nil) if l.nil?
                #l.logs "Flag delivery start... "
                self.start_delivery
                #l.done
                begin
                    #l.logs "Deliver... "
                    address = self.address
                    campaign = self.followup.campaign    
                    message_id = address.send({
                        :to_email => self.email, 
                        :to_name => "#{self.lead.first_name} #{self.lead.last_name}".strip,
                        :subject => self.subject, 
                        :body => self.body, 
                        :from_name => address.name, 
                        #:reply_to => campaign.reply_to,
                        :text_only =>  self.followup.type == BlackStack::Emails::Followup::TYPE_TEXT
                    })
                    #l.done

                    #l.logs "Flag delivery end... "
                    self.end_delivery(nil, message_id)
                    #l.done

                    # track log
                    #l.logs 'Track log... '
                    self.track('sent')
                    #l.done
                rescue => e
                    #l.logf "Error: #{e.message}"

                    #l.logs "Flag delivery end with error... "
                    self.end_delivery(e.message)
                    #l.done

                    # track log
                    #l.logs 'Track log with error... '
                    self.track('failed', nil, e.message)
                    #l.done
                end
            end

            # return the url of the pixel for open tracking
            def pixel_url
                ret = nil
                errors = []
                # validation: self.id is not nil and it is a valid guid
                errors << "id is nil" if self.id.nil? || !self.id.guid?
                # validation: self.address is not nil
                errors << "address is nil" if self.address.nil?
                # if any error happened, raise an exception
                raise errors.join(", ") if errors.size > 0
                # return
                return "#{self.address.tracking_url}/api1.0/emails/open.json?did=#{self.id.to_guid}"
            end  

            # return the url of the pixel for click tracking
            def pixel
                "<img src='#{self.pixel_url}' height='1px' width='1px' />"
            end

            def unsubscribe_url
                "#{self.address.tracking_url}/api1.0/emails/unsubscribe.json?did=#{self.id.to_guid}"
            end

            # apply pixel for tracking opens.
            # apply tracking links.
            # apply unsubscribe link.
            # finally, call the save method of the parent class.
            def after_create
                # call the parent class save method.
                super
                # this trigger is for replies from the leads.
                return if self.is_response
                # this trigger is not for manually created deliveries.
                return if self.is_single
                # apply pixel for tracking opens.
                if self.followup.type == BlackStack::Emails::Followup::TYPE_HTML
                    # apply pixel for tracking opens.
                    if self.followup.track_opens_enabled
                        self.body += self.pixel
                    end
                    # apply tracking links.
                    # iterate all href attributes of anchor tags
                    # reference: https://stackoverflow.com/questions/53766997/replacing-links-in-the-content-with-processed-links-in-rails-using-nokogiri
                    if self.followup.track_clicks_enabled
                        n = 0
                        fragment = Nokogiri::HTML.fragment(self.body)
                        fragment.css("a[href]").each do |link| 
                            # increment the URL counter
                            n += 1
                            # get the link
                            l = BlackStack::Emails::Link.where(:id_followup=>self.id_followup, :link_number=>n, :delete_time=>nil).first
                            # validate the link URL
                            raise "Link #{n} is not found." if l.nil?
                            raise "Link #{n} #{l.url} don't match with #{link['href']}." if l.url != link['href']
                            # replace the link with the tracking link
                            link['href'] = l.tracking_url(self)
                        end
                        # update notification body.
                        self.body = fragment.to_html
                        # this forcing is because of this glitch: https://github.com/sparklemotion/nokogiri/issues/1127
                        self.body.gsub!(/#{Regexp.escape('&amp;')}/, '&')
                        # apply unsubscribe link.
                        self.body.gsub!(/#{Regexp.escape(BlackStack::Emails::UNSUBSCRIBE_MERGETAG)}/, self.unsubscribe_url)        
                    end
                end
                # write history in eml_log
                self.track('pending')
                # save the changes.
                self.save
            end

            # return the previous delivery for an envelop object
            def self.previous(addr, imap, id, envelope)
                d = nil

                # getting the parameters
                from_name = envelope.from[0].name
                from_email = envelope.from[0].mailbox.to_s + '@' + envelope.from[0].host.to_s 
                date = envelope.date

                # TODO: develop a normalization function for mail.message_id
                message_id = envelope.message_id.to_s.gsub(/^</, '').gsub(/>$/, '')

                # TODO: develop a normalization function for mail.in_reply_to
                in_reply_to = envelope.in_reply_to.to_s.gsub(/^</, '').gsub(/>$/, '') # use this parameter to track a conversation thread
                subject = envelope.subject
                body = imap.fetch(id, "BODY[]")[0].attr["BODY[]"]

                # find the delivery
                if !in_reply_to.to_s.empty?
                    d = BlackStack::Emails::Delivery.where(:message_id => in_reply_to).first 
                end

                # problem: when delivery with postmark, the message_id of the sent message is not the same as the in_reply_to
                # solution: use the email and the subject
                if d.nil?
                    d = BlackStack::Emails::Delivery.where(:id_address=>addr.id, :email => from_email, :is_response=>false).reverse(:create_time).all.select { |d| subject =~ /#{Regexp.escape(d.subject)}/i }.first
                end

                # problem: the lead replied from another email address. 
                # There is no solution. it is not possible to track the conversation. 
                # solution: register the message as a new conversation, outside of this method.

                # return
                d
            end

            # create merge sender name and sender email address with the list of leads beloning the owner of the address.
            # Note: if the address is shared, there is no way to know who exactly is the owner of the lead.
            def self.register_new_conversation(addr, imap, id, envelope)
                # getting the parameters
                from_name = envelope.from[0].name
                from_email = envelope.from[0].mailbox.to_s + '@' + envelope.from[0].host.to_s 
                date = envelope.date

                # TODO: develop a normalization function for mail.message_id
                message_id = envelope.message_id.to_s.gsub(/^</, '').gsub(/>$/, '')

                # if the reply is already registered, then return it.
                r = BlackStack::Emails::Delivery.select(:id).where(:message_id=>message_id).first
                return r if !r.nil?

                # TODO: develop a normalization function for mail.in_reply_to
                in_reply_to = envelope.in_reply_to.to_s.gsub(/^</, '').gsub(/>$/, '') # use this parameter to track a conversation thread
                subject = envelope.subject
                body = imap.fetch(id, "BODY[]")[0].attr["BODY[]"]

                # register a new lead lead
                o = BlackStack::Leads::Lead.merge ({
                    'name' => from_name.to_s,
                    'id_user' => addr.id_user,
                    'datas' => [
                        {
                            'type' => BlackStack::Leads::Data::TYPE_EMAIL,
                            'value' => from_email.to_s,
                        },
                    ],
                })
                o.save

                # register a new delivery
                rep = Sisimai.make(body)
                r = BlackStack::Emails::Delivery.new
                r.id = guid
                r.id_followup = nil
                r.id_lead = o.id
                r.create_time = now
                r.name = from_name
                r.email = from_email
                r.subject = subject
                r.body = body
                r.is_bounce = !rep.nil?
                r.bounce_reason = rep[0].reason if rep
                r.bounce_diagnosticcode = rep[0].diagnosticcode if rep
                r.message_id = message_id
                r.id_user = addr.id_user # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_address = addr.id # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_conversation = guid
                r.is_response = true # very important flag!
                r.id_template = nil
                r.delivery_end_time = date
                r.save

                # return
                r
            end

            # insert reply from the lead to the database.
            # reutrn the new delivery object.
            def insert_reply(imap, id, envelope)
                # getting the parameters
                from_name = envelope.from[0].name
                from_email = envelope.from[0].mailbox.to_s + '@' + envelope.from[0].host.to_s 
                date = envelope.date

                # TODO: develop a normalization function for mail.message_id
                message_id = envelope.message_id.to_s.gsub(/^</, '').gsub(/>$/, '')

                # if the reply is already registered, then return it.
                r = BlackStack::Emails::Delivery.select(:id).where(:message_id=>message_id).first
                return r if !r.nil?

                # TODO: develop a normalization function for mail.in_reply_to
                in_reply_to = envelope.in_reply_to.to_s.gsub(/^</, '').gsub(/>$/, '') # use this parameter to track a conversation thread
                subject = envelope.subject
                body = imap.fetch(id, "BODY[]")[0].attr["BODY[]"]

                # create a conversation id
                if self.id_conversation.nil?
                    self.id_conversation = guid
                    DB.execute("UPDATE eml_delivery SET id_conversation = '#{self.id_conversation}' WHERE id = '#{self.id}'")
                end
                # decide if it is a bounce report
                rep = Sisimai.make(body)
                # insert the reply
                r = BlackStack::Emails::Delivery.new
                r.id = guid
                r.id_followup = self.id_followup
                r.id_lead = self.id_lead
                r.create_time = now
                r.name = from_name
                r.email = from_email
                r.subject = subject
                r.body = body
                r.is_bounce = !rep.nil?
                r.bounce_reason = rep[0].reason if rep
                r.bounce_diagnosticcode = rep[0].diagnosticcode if rep
                r.message_id = message_id
                r.id_user = self.id_user # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_address = self.id_address # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                r.id_conversation = self.id_conversation
                r.is_response = true # very important flag!
                r.id_template = self.id_template
                r.delivery_end_time = date
                r.save
                # track - write history in eml_log
                self.track('reply')
                # return 
                r
            end # def insert_reply(subject, from_name, from_email, date, message_id, body)

        end # class Delivery
    end # Emails
end # BlackStack