module BlackStack
    module Emails
        class Followup < Sequel::Model(:eml_followup)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign      
            one_to_many :jobs, :class=>:'BlackStack::Emails::Job', :key=>:id_followup

            # types of email campaigns: text or html
            TYPE_TEXT = 0
            TYPE_HTML = 1

            # statuses of email campaigns: draft, sent, etc.
            STATUS_DRAFT = 0
            STATUS_ON = 1
            STATUS_OFF = 2
            STATUS_ERROR = 3

            # return true if stat_left needs to be updated
            def self.ids_for_left_update
                # stat_sents
                return DB["
                    SELECT DISTINCT f.id 
                    FROM eml_delivery d
                    JOIN eml_followup f ON f.id=d.id_followup
                    JOIN eml_campaign c ON (
                        c.id=f.id_campaign and 
                        c.archive_success is null and 
                        c.archive_start_time is null
                    ) -- leandrosardi/cs#100
                    WHERE d.create_time > COALESCE(f.timeline_start_time, '2000-01-01 00:00:00')
                    AND COALESCE(d.is_response, false) = false
                    AND COALESCE(d.is_bounce, false) = false
                    AND COALESCE(d.delivery_success, false) = true
                "].all.map { |row| row[:id] }
            end 

            # return true if stats need to be updated
            def need_timeline_update?
                # stat_sents
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    WHERE d.create_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    AND COALESCE(d.is_response, false) = false
                    AND COALESCE(d.is_bounce, false) = false
                    AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
=begin
                # stat_sents
                # stat_replies
                # stat_bounces
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    WHERE d.create_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    --AND COALESCE(d.is_response, false) = false
                    --AND COALESCE(d.is_bounce, false) = false
                    --AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
                # stat_positive_replies
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    WHERE d.positive_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    --AND COALESCE(d.is_response, false) = false
                    --AND COALESCE(d.is_bounce, false) = false
                    --AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
                # stat_opens
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    JOIN eml_open o ON o.id_delivery=d.id
                    WHERE o.create_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    --AND COALESCE(d.is_response, false) = false
                    --AND COALESCE(d.is_bounce, false) = false
                    --AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
                # stat_click
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    JOIN eml_click o ON o.id_delivery=d.id
                    WHERE o.create_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    --AND COALESCE(d.is_response, false) = false
                    --AND COALESCE(d.is_bounce, false) = false
                    --AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
                # stat_unsubscribes
                return true if DB["
                    SELECT COUNT(DISTINCT d.id_lead) AS n 
                    FROM eml_delivery d
                    JOIN eml_unsubscribe o ON o.id_delivery=d.id
                    WHERE o.create_time > '#{self.timeline_start_time.nil? ? '2000-01-01 00:00:00' : self.timeline_start_time}'
                    AND d.id_followup = '#{self.id}'
                    --AND COALESCE(d.is_response, false) = false
                    --AND COALESCE(d.is_bounce, false) = false
                    --AND COALESCE(d.delivery_success, false) = true
                "].first[:n] > 0
=end
                # return false
                false
            end # need_timeline_update?

            # types
            def self.types
                [TYPE_TEXT, TYPE_HTML]
            end

            def self.type_name(n)
                case n
                when TYPE_TEXT
                    'Text'
                when TYPE_HTML
                    'HTML'
                else
                    'Unknown'
                end
            end

            def type_name
                BlackStack::Emails::Followup.type_name(self.type)
            end

            def self.type_color(n)
                case n
                when TYPE_TEXT
                    'blue'
                when TYPE_HTML
                    'green'
                else
                    'red'
                end
            end

            def type_color
                BlackStack::Emails::Followup.type_color(self.type)
            end

            # statuses of email campaigns: draft, sent, etc.
            def self.statuses
                [STATUS_DRAFT, STATUS_ON, STATUS_OFF, STATUS_ERROR]
            end

            def self.status_name(n)
                case n
                when STATUS_DRAFT
                    'Draft'
                when STATUS_ON
                    'On'
                when STATUS_OFF
                    'Off'
                when STATUS_ERROR
                    'Error'
                else
                    'Unknown'
                end
            end

            def status_name
                BlackStack::Emails::Followup.status_name(self.status)
            end

            def status_color
                case self.status
                when STATUS_DRAFT
                    'blue'
                when STATUS_ON
                    'green'
                when STATUS_OFF
                    'gray'
                when STATUS_ERROR
                    'red'
                end
            end

            def can_edit?
                self.status == STATUS_DRAFT
            end

            def can_play?
                self.status == STATUS_DRAFT || self.status == STATUS_OFF
            end

            def can_pause?
                self.status == STATUS_ON
            end
            
            # leads in the export list.
            # note that may exist leads added after the campaign planning.
            def total_leads
                DB["
                    SELECT COUNT(el.*) AS n 
                    FROM fl_export_lead el
                    #{self.campaign.use_public_addresses ? 'JOIN fl_lead l ON l.id=el.id_lead' : ''}
                    WHERE id_export = '#{self.campaign.id_export}'
                "].first[:n]
            end

            # total number of deliveries planned for this campaign
            def total_deliveries
                DB["
                    SELECT COUNT(*) AS n 
                    FROM eml_delivery d 
                    WHERE d.id_followup = '#{self.id}'
                "].first[:n]
            end

            def self.ids_for_stats_update
                DB["
                    -- followups beloging...
                    select f.id
                    from eml_followup f
                    where f.id_campaign in (
                        -- campaigns with new deliveries (sents, responses, bounces)
                        select f.id_campaign
                        from eml_followup f
                        join eml_delivery d on f.id=d.id_followup
                        where f.delete_time is null 
                        and d.create_time > coalesce(f.timeline_end_time, '2000-01-01')
                        group by f.id
                        union
                        -- campaigns with new opens
                        select f.id_campaign
                        from eml_followup f
                        join eml_delivery d on f.id=d.id_followup
                        join eml_open o on d.id=o.id_delivery 
                        where f.delete_time is null 
                        and o.create_time > coalesce(f.timeline_end_time, '2000-01-01')
                        group by f.id
                        union
                        -- campaigns with new clicks
                        select f.id_campaign
                        from eml_followup f
                        join eml_delivery d on f.id=d.id_followup
                        join eml_click o on d.id=o.id_delivery 
                        where f.delete_time is null 
                        and o.create_time > coalesce(f.timeline_end_time, '2000-01-01')
                        group by f.id
                        union
                        -- campaigns with new unsubscribes
                        select f.id_campaign
                        from eml_followup f
                        join eml_delivery d on f.id=d.id_followup
                        join eml_unsubscribe o on d.id=o.id_delivery 
                        where f.delete_time is null 
                        and o.create_time > coalesce(f.timeline_end_time, '2000-01-01')
                        group by f.id                
                    )
                "].map(:id)
            end

            def update_stats
                rows = DB[BlackStack::Emails.query_sents(nil, nil, nil, self.id, nil)].all
                self.stat_sents = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unique_opens(nil, nil, nil, self.id, nil)].all
                self.stat_opens = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unique_clicks(nil, nil, nil, self.id, nil)].all
                self.stat_clicks = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_bounces(nil, nil, nil, self.id, nil)].all
                self.stat_bounces = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_replies(nil, nil, nil, self.id, nil)].all
                self.stat_replies = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unsubscribes(nil, nil, nil, self.id, nil)].all
                self.stat_unsubscribes = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_positive_replies(nil, nil, nil, self.id, nil)].all
                self.stat_positive_replies = rows.map { |row| row[:n] }.sum
                
                self.stat_left = self.get_count_of_pending_leads

                self.save
            end

            def sent_ratio
                t = self.stat_left + self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_sents.to_f / t.to_f) * 100.to_f).to_f
            end

            def bounces_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_bounces.to_f / t.to_f) * 100.to_f).to_f
            end

            def opens_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_opens.to_f / t.to_f) * 100.to_f).to_f
            end

            def clicks_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_clicks.to_f / t.to_f) * 100.to_f).to_f
            end

            def replies_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_replies.to_f / t.to_f) * 100.to_f).to_f
            end

            def positive_replies_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_positive_replies.to_f / t.to_f) * 100.to_f).to_f
            end

            def unsubscribes_ratio
                t = self.stat_sents
                t == 0 ? 0.to_f : ((self.stat_unsubscribes.to_f / t.to_f) * 100.to_f).to_f
            end

            def get_id_addresses(n=-1)
                ids = []
                followup = self
                campaign = self.campaign
                user = self.campaign.user
#binding.pry
                # private addresses assigned to this campaign by tag
                if campaign.use_private_addresses
                    ids += BlackStack::Emails::Address.get_ids_of_available_addresses(
                        n, false, user.id_account, followup.id_campaign
                    )
                end # if campaign.use_public_addresses
                # if I didn't find addresses enough, and 
                # if the campaign allow to use shared addresses,
                # then I look for shared addresses                
                if ids.size < n || n == -1
                    if campaign.use_public_addresses
                        # shared addresses by any user
                        ids += BlackStack::Emails::Address.get_ids_of_available_addresses(
                            n, true, nil, nil
                        )
                    end
                end
                # return
                ids
            end # def get_id_addresses 

            def get_addresses(n)
                addresses = []
                # load objects
                self.get_id_addresses(n).each do |id|
                    addresses << BlackStack::Emails::Address.where(:id=>id).first
                end
                # return 
                addresses
            end

            # find all the substrings that match with /\{.*\}/, with an optional additonal '{' char at the beginning, and doesn't include the char '|' inside.
            # validate such substring is '{first-name}' or '{company-name}'
            # otherwise, raise an exception
            #
            # If no error found, return the array of merge-tags found.
            #
            def self.validate_mergetags(s)
                s = Nokogiri::HTML.parse(s).text
                # find all the substrings that match with /\{.*\}/ and doesn't include the char '|' inside.
                s.scan(/\{[^|]*\}/).each { |m|
                    # validate such substring is '{first-name}' or '{company-name}'
                    raise "Invalid merge-tag: #{m}" unless ['{first-name}','{company-name}','{{first-name}','{{company-name}'].include?(m)
                }
            end
  
            # reutrn true if s is a valid spintax string
            # otherwise, raise an exception
            def self.validate_spintax(s)
                s = Nokogiri::HTML.parse(s).text
                # find all the substrings that match with /\{.*\}/ and doesn't include the char '|' inside.
                s.spintax?
            end 

            def validate_mergetags
                BlackStack::Emails::Followup.validate_mergetags(self.subject) + BlackStack::Emails::Followup.validate_mergetags(self.body)
            end

            def validate_spintax
                BlackStack::Emails::Followup.validate_spintax(self.subject) && BlackStack::Emails::Followup.validate_spintax(self.body)
            end

            # replace merge-tags in the string s with the values of the lead's atrtibutes.
            # return the string with the merge-tags replaced.
            # this is a general purpose method to send email.
            # this should not call this method.
            def merge(s, lead)
                ret = s.dup
                email = lead.emails.first.nil? ? '' : lead.emails.first.value
                phone = lead.phones.first.nil? ? '' : lead.phones.first.value
                linkd = lead.linkedins.first.nil? ? '' : lead.linkedins.first.value

                # replace merge-tags with no fallback values
                ret.gsub!(/#{Regexp.escape('{company-name}')}/, lead.stat_company_name.to_s)
                ret.gsub!(/#{Regexp.escape('{first-name}')}/, lead.first_name.to_s)
                ret.gsub!(/#{Regexp.escape('{last-name}')}/, lead.last_name.to_s)
                ret.gsub!(/#{Regexp.escape('{location}')}/, lead.stat_location_name.to_s)
                ret.gsub!(/#{Regexp.escape('{industry}')}/, lead.stat_industry_name.to_s)
                ret.gsub!(/#{Regexp.escape('{email-address}')}/, email.to_s)
                ret.gsub!(/#{Regexp.escape('{phone-number}')}/, phone.to_s)
                ret.gsub!(/#{Regexp.escape('{linkedin-url}')}/, linkd.to_s)

                # replace merge-tags with fallback values
                ret.scan(/#{Regexp.escape('{company-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_company_name.to_s.empty? ? m.gsub(/^\{company-name\|/, '').gsub(/\}$/, '') : lead.stat_company_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{first-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.first_name.to_s.empty? ? m.gsub(/^\{first-name\|/, '').gsub(/\}$/, '') : lead.first_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{last-name|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.last_name.to_s.empty? ? m.gsub(/^\{last-name\|/, '').gsub(/\}$/, '') : lead.last_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{location|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_location_name.to_s.empty? ? m.gsub(/^\{location\|/, '').gsub(/\}$/, '') : lead.stat_location_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{industry|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, lead.stat_industry_name.to_s.empty? ? m.gsub(/^\{industry\|/, '').gsub(/\}$/, '') : lead.stat_industry_name.to_s)
                } 
                ret.scan(/#{Regexp.escape('{email-address|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, email.to_s.empty? ? m.gsub(/^\{email-address\|/, '').gsub(/\}$/, '') : email.to_s)
                } 
                ret.scan(/#{Regexp.escape('{phone-number|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, phone.to_s.empty? ? m.gsub(/^\{phone-number\|/, '').gsub(/\}$/, '') : phone.to_s)
                } 
                ret.scan(/#{Regexp.escape('{linkedin-url|')}.*#{Regexp.escape('}')}/).each { |m| 
                    ret.sub!(m, linkd.to_s.empty? ? m.gsub(/^\{linkedin-url\|/, '').gsub(/\}$/, '') : linkd.to_s)
                } 
                # return
                ret             
            end

            # replace merge-tags in the subject with the values of the lead's atrtibutes.
            # return the subject with the merge-tags replaced.
            def merged_subject(lead)
                merge(self.subject, lead)
            end

            # replace merge-tags in the body with the values of the lead's atrtibutes.
            # return the body with the merge-tags replaced.
            def merged_body(lead)
                merge(self.body, lead)
            end

            # update the planning flags of this campaign
            def start_planning()
                DB.execute("UPDATE eml_followup SET planning_start_time = '#{now}', planning_end_time = NULL, planning_success = NULL, planning_error_description = NULL WHERE id = '#{self.id}'")
            end

            # update the planning flags of this campaign
            def end_planning(error=nil)
                DB.execute("UPDATE eml_followup SET planning_end_time = '#{now}', planning_success = #{error.nil?}, planning_error_description = #{error.nil? ? 'NULL' : "'#{error.to_sql}'"} WHERE id = '#{self.id}'")
            end

            # create a deliver
            # return the delivery
            # 
            # choice 1, use the first email address of the lead.
            # choice 2, use ANY email address of the lead.
            # 
            def create_delivery(lead, id_address)
                email = lead.emails.first
                raise 'Email address not found' if email.nil?
                d = BlackStack::Emails::Delivery.new
                d.id = guid
                d.id_followup = self.id
                d.id_address = id_address
                d.id_lead = lead.id
                d.create_time = now
                # parameters
                d.email = email.value
                d.subject = self.merged_subject(lead).spin
                d.body = self.merged_body(lead).spin
                d.id_user = self.id_user # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                d.id_address = id_address # this parameter is replicated (unnormalized), because the `eml_delivery` table is use to register manually sent (individual) emails too.
                d.save
                # release resources
                GC.start
                DB.disconnect
                #
                d
            end

            # delete all the record in the table `eml_link` regarding this campaign.
            # create new record in the table `eml_link` for each anchor in the body.
            # call the `save` method of the parent class to save the changes.
            def update_links
                # number of URL in the body
                n = 0

                # delete all the record in the table `eml_link` regarding this campaign.
                BlackStack::Emails::Link.where(:id_followup=>self.id, :delete_time=>nil).all { |link|
                    DB.execute("UPDATE eml_link SET delete_time='#{now}' WHERE id='#{link.id}'")
                    GC.start
                    DB.disconnect
                }

                # create new record in the table `eml_link` for each anchor in the body.
                # iterate all href attributes of anchor tags
                # reference: https://stackoverflow.com/questions/53766997/replacing-links-in-the-content-with-processed-links-in-rails-using-nokogiri
                fragment = Nokogiri::HTML.fragment(self.body)
                fragment.css("a[href]").each do |link| 
                    # increment the URL counter
                    n += 1
                    # create and save the object BlackStack::Emails::Link
                    o = BlackStack::Emails::Link.new
                    o.id = guid
                    o.id_followup = self.id
                    o.create_time = now
                    o.link_number = n
                    o.url = link['href']
                    o.save
                end
            end

            # trigger
            def after_create
                # call the `save` method of the parent class to save the changes.
                super
                # update the links
                update_links
            end

            # trigger
            def after_update
                # call the `save` method of the parent class to save the changes.
                super
                # update the links
                update_links
            end

            # return a query to get IDs of leads allowed to be reached by this followup right now
            def get_query_of_pending_leads
                a = nil
                b = nil
                c = nil
                d = nil
                q = nil
                # if sequence == 1, simply select all the leads.
                # else, build list of leads who delivered for previous followup, `delay_days` ago or before.
                if self.sequence_number.to_i == 1
                    a = "
                        select distinct x.id_lead
                        --select count(x.id), count(distinct x.id_lead)
                        from eml_followup f
                        join eml_campaign g on g.id=f.id_campaign
                        join fl_export e on e.id=g.id_export 
                        join fl_export_lead x on e.id=x.id_export
                        join fl_lead l ON l.id=x.id_lead
                        join fl_data d on (l.id=d.id_lead and d.type=20 and d.delete_time is null)
                        where f.id='#{self.id}'
                        and x.create_time < CAST('#{now()}' AS TIMESTAMP) - INTERVAL '#{self.delay_days} DAYS'
                    "
                else # sequence_number > 1
                    a = "
                        select distinct x.id_lead
                        --select count(x.id), count(distinct x.id_lead)
                        from eml_followup f
                        join eml_campaign g on g.id=f.id_campaign
                        join fl_export e on e.id=g.id_export 
                        join fl_export_lead x on e.id=x.id_export
                        join fl_lead l ON l.id=x.id_lead
                        join fl_data d on (l.id=d.id_lead and d.type=20 and d.delete_time is null)
                        join eml_delivery d on ( 
                            d.id_lead=x.id_lead and 
                            d.delivery_end_time is not null and 
                            d.delivery_success = true and 
                            d.delivery_end_time < CAST('#{now()}' AS TIMESTAMP) - INTERVAL '#{self.delay_days} DAYS'
                        )
                        join eml_followup h on (
                            h.id = d.id_followup and
                            f.id_campaign=h.id_campaign and 
                            f.sequence_number=h.sequence_number+1
                        )
                        where f.id='#{self.id}'
                    "
                end 

                if self.campaign.exclude_leads_reached_by_another_campaign
                    # build list of leads who have a delivery (pending or not) 
                    # for same followup sequence_number, 
                    # in this same account
                    b = "
                        select distinct d.id_lead
                        --select count(d.id), count(distinct d.id_lead)
                        from eml_delivery d
                        join eml_followup f on (
                            f.id=d.id_followup and 
                            f.sequence_number=#{self.sequence_number}
                        )
                        join eml_campaign g on g.id=f.id_campaign
                        join \"user\" u on (u.id=g.id_user and u.id_account='#{self.campaign.user.id_account}')
                        --where d.delivery_success = true
                        where d.delete_time is null
                    "
                else
                    # build list of leads who have a delivery (pending or not) 
                    # for same followup sequence_number, 
                    # in this same campaign
                    b = "
                        select distinct d.id_lead
                        --select count(d.id), count(distinct d.id_lead)
                        from eml_delivery d
                        join eml_followup f on (
                            f.id=d.id_followup and 
                            f.sequence_number=#{self.sequence_number} and
                            f.id_campaign='#{self.id_campaign}'
                        )
                        --where d.delivery_success = true
                        where d.delete_time is null
                    "
                end
                # remove any lead unsubscribed for the same list than the export list of this followup
                c = "
                    except
                    select distinct d.id_lead
                    from eml_unsubscribe u
                    join eml_delivery d on d.id=u.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join eml_campaign g on (g.id=f.id_campaign and g.id_export='#{self.campaign.id_export}')
                "
                # remove any lead for who replied for this campaign
                d = ''
                if self.campaign.stop_followups_if_lead_replied
                    d = "
                        except
                        select distinct d.id_lead
                        from eml_delivery d 
                        join eml_followup f on (
                            f.id=d.id_followup and
                            f.id_campaign='#{self.id_campaign}'
                        )
                        where d.is_response = true
                    "
                end
                # build query
                q = "
                    #{a}
                    except
                    #{b}
                    #{c}
                    #{d}
                    -- exclude leads with delivery (success or no) in last 1 hours
                    except
                    select distinct d.id_lead
                    from eml_delivery d
                    where d.create_time > CAST('#{now()}' AS TIMESTAMP) - INTERVAL '1 HOUR'
                    and d.is_response = false
                    -- exclude leads with more than 3 failed deliveries for this followup
                    except
                    select d.id_lead
                    from eml_delivery d
                    where d.delivery_success = false
                    and d.is_response = false
                    and d.id_followup='#{self.id}'
                    group by d.id_lead
                    having count(d.id) > 3
                "
                # return 
                q
            end

            # return the total number of leads allowed to be reached by this followup right now
            def get_count_of_pending_leads
                # build query
                q = "
                select count(v.id_lead) as n
                from (
                    #{self.get_query_of_pending_leads}
                ) as v
                "
                # return
                DB[q].first[:n].to_i
            end # get_count_of_pending_leads

            # return an array of IDs of leads allowed to be reached by this followup right now
            def get_ids_of_pending_leads(n=100)
                # build query
                q = "
                select v.id_lead
                from (
                    #{self.get_query_of_pending_leads}
                ) as v
                limit #{n.to_s}              
                "
                # return
                DB[q].all.map { |row| row[:id_lead] }
            end # get_ids_of_pending_leads

            # return an array of leads allowed to be reached by this followup right now
            def get_pending_leads(n=100)
                ret = []
                # load the leads
                self.get_ids_of_pending_leads(n).each { |id_lead|
                    ret << BlackStack::Leads::Lead.where(:id=>id_lead).first
                    # release resources
                    DB.disconnect
                    GC.start
                }
                # return
                ret
            end
        end # class Followup
    end # Emails
end # BlackStack