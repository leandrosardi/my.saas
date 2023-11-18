module BlackStack
    module Emails
        class Campaign < Sequel::Model(:eml_campaign)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export      
            one_to_many :followups, :class=>"BlackStack::Emails::Followup", :key=>:id_campaign
            one_to_many :schedules, :class=>"BlackStack::Emails::Schedule", :key=>:id_campaign
            one_to_many :outreaches, :class=>"BlackStack::Emails::Outreach", :key=>:id_campaign
            
            # statuses of email campaigns: draft, sent, etc.
            STATUS_ON = 1
            STATUS_OFF = 2

            # return campaigns if non-premium accounts with deliveries
            # no need to filter by `archive_success`, because any campaign with deliveries will be archived
            def self.ids_to_archive()
                q = "
                    select a.name, a.id, f.id_campaign, count(d.id) as n_deliveries
                    --select count(distinct a.id) as accounts, count(distinct f.id_campaign) as campaigns, count(distinct f.id) as followups, count(distinct d.id) as deliveries
                    from account a 
                    join \"user\" u on a.id=u.id_account
                    join eml_followup f on u.id=f.id_user
                    join eml_delivery d on f.id=d.id_followup
                    where coalesce(a.premium,false)=false
                    group by a.name, a.id, f.id_campaign
                "
                DB[q].all.map { |r| r[:id_campaign] }
            end

            # This method is for internal use only,
            # End-users should not call this method directly
            # 
            # Archive the following tables
            # - eml_log
            # - eml_open
            # - eml_click
            # - eml_unsubscribe
            # - eml_action_log
            # - eml_delivery
            # 
            def self.archive(id, n=200, l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
        
                    # eml_log
                    l.logs 'archiving eml_log... '
                        n = DB.execute("
                            insert into eml_log_history 
                            select x.*
                            from eml_log x
                            where x.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")                
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_action_log... '
                        n = DB.execute("
                            delete from eml_log where id in (select id from eml_log_history) limit #{n} 
                        ")
                    l.done
                    return false if n > 0

                    # eml_open
                    l.logs 'archiving eml_open... '
                    n = DB.execute("
                            insert into eml_open_history 
                            select x.*
                            from eml_open x
                            join eml_delivery d on d.id=x.id_delivery 
                            join eml_followup f on f.id=d.id_followup class Campaign
                            where f.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_open... '
                        n = DB.execute("
                            delete from eml_open where id in (select id from eml_open_history) limit #{n} 
                        ")
                    l.done
                    return false if n > 0

                    # eml_click
                    l.logs 'archiving eml_click... '
                        n = DB.execute("
                            insert into eml_click_history 
                            select x.*
                            from eml_click x
                            join eml_delivery d on d.id=x.id_delivery
                            join eml_followup f on f.id=d.id_followup 
                            where f.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_click... '
                        n = DB.execute("
                            delete from eml_click where id in (select id from eml_click_history) limit #{n} 
                        ")
                    l.done
                    return false if n > 0

                    # eml_unusbscribe
                    l.logs 'archiving eml_unsubscribe... '
                        n = DB.execute("
                            insert into eml_unsubscribe_history 
                            select x.*
                            from eml_unsubscribe x
                            join eml_delivery d on d.id=x.id_delivery 
                            join eml_followup f on f.id=d.id_followup 
                            where f.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_unsubscribe... '
                        n = DB.execute("
                            delete from eml_unsubscribe where id in (select id from eml_unsubscribe_history) limit #{n} 
                        ")
                    l.done
                    return false if n > 0

                    # eml_action_log
                    l.logs 'archiving eml_action_log... '
                        n = DB.execute("
                            insert into eml_action_log_history 
                            select x.*
                            from eml_action_log x 
                            join eml_action a on a.id=x.id_action 
                            join eml_followup f on f.id=a.id_followup 
                            where f.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_action_log... '
                        n = DB.execute("
                            delete from eml_action_log where id in (select id from eml_action_log_history) limit #{n} 
                        ")
                    l.done
                    return false if n > 0

                    # eml_delivery
                    l.logs 'archiving eml_delivery... '
                        n = DB.execute("
                            insert into eml_delivery_history 
                            select x.*
                            from eml_delivery x 
                            join eml_followup f on f.id=x.id_followup 
                            where f.id_campaign = '#{id}'
                            limit #{n}
                            on conflict do nothing
                        ")
                    l.done
                    return false if n > 0

                    l.logs 'deleting eml_delivery... '
                        n = DB.execute("
                            delete from eml_delivery where id in (select id from eml_delivery_history) limit #{n}                 
                        ")
                    l.done
                    return false if n > 0

                    return true
            end

            def archive(l=nil)
                begin
                    l.logs 'flag archiving start... '
                    self.flag_archive_start
                    l.done
    
                    res = false
                    while !res
                        res = BlackStack::Emails::Campaign.archive(self.id, 200, l)
                    end

                    l.logs 'flag archiving end... '
                    self.flag_archive_end
                    l.done
                rescue => e
                    l.log "error: #{e.message}"

                    l.logs 'flag archiving error... '
                    self.flag_archive_end(false, e.message)
                    l.done        
                end 
            end

            def flag_archive_start
                DB.execute("update eml_campaign set archive_start_time = cast('#{now}' as timestamp) where id = '#{self.id}'")
            end

            def flag_archive_end(result=true, error=nil)
                DB.execute("
                    update eml_campaign set 
                        archive_end_time = cast('#{now}' as timestamp), 
                        archive_success=#{result ? 'true' : 'false'},
                        archive_error_description=#{error.nil? ? 'null' : "'#{error.to_sql}'"}  
                    where id = '#{self.id}'")
            end

            # if the campaign has not schedules, then return `true`.
            # else,
            # - return true if one of the schedules of the campaig is at the moment (is_in_schedule?)
            def is_in_schedule?
                arr = self.schedules.select { |s| s.delete_time.nil? } 
                return true if arr.size == 0
                arr.each { |s| 
                    return true if s.is_in_schedule?
                }
                return false
            end

            # return array of tag objects, connected to this campaign thru the :outreaches attribute
            def tags()
                self.outreaches.map { |o| o.tag }.uniq
            end

            # return array of address objects, connected to this campaign thru the :outreaches attribute
            def addresses()
                self.outreaches.map { |o| o.tag }.uniq.map { |t| t.addresses }.flatten.uniq
            end

            # statuses of email campaigns: draft, sent, etc.
            def self.statuses
                [STATUS_ON, STATUS_OFF]
            end

            # can edit if there is not any followup who can't edit
            def can_edit?
                self.followups.select { |f| !f.can_edit? }.first.nil?
            end

            # if is ON if any followup is ON
            def status
                self.followups.select { |f| f.status == BlackStack::Emails::Followup::STATUS_ON }.first.nil? ? STATUS_OFF : STATUS_ON
            end 

            # if is ON if any followup is ON
            def self.status_name(n)
                n == STATUS_ON ? 'on' : 'off'
            end

            # if is ON if any followup is ON
            def status_name
                BlackStack::Emails::Campaign.status_name(self.status)
            end

            def self.status_color(n)
                case n
                when STATUS_ON
                    'green'
                when STATUS_OFF
                    'gray'
                end
            end

            def status_color
                BlackStack::Emails::Campaign.status_color(self.status)
            end

            # leads in the export list.
            # note that may exist leads added after the campaign planning.
            def total_leads
                DB["SELECT COUNT(*) AS n FROM fl_export_lead WHERE id_export = '#{self.id_export}'"].first[:n]
            end

            # total number of deliveries planned for this campaign
            def total_deliveries
                DB["
                    SELECT COUNT(*) AS n 
                    FROM eml_followup f
                    JOIN eml_delivery d on f.id=d.id_followup 
                    WHERE f.id_campaign = '#{self.id}'
                "].first[:n]
            end

            def self.ids_for_stats_update
                DB["
                    -- campaigns with new deliveries (sents, responses, bounces)
                    select c.id
                    from eml_campaign c
                    join eml_followup f on c.id=c.id 
                    join eml_delivery d on f.id=d.id_followup
                    where c.delete_time is null 
                    and d.create_time > coalesce(c.timeline_end_time, '2000-01-01')
                    group by c.id
                    union
                    -- campaigns with new opens
                    select c.id
                    from eml_campaign c
                    join eml_followup f on c.id=c.id 
                    join eml_delivery d on f.id=d.id_followup
                    join eml_open o on d.id=o.id_delivery 
                    where c.delete_time is null 
                    and o.create_time > coalesce(c.timeline_end_time, '2000-01-01')
                    group by c.id
                    union
                    -- campaigns with new clicks
                    select c.id
                    from eml_campaign c
                    join eml_followup f on c.id=c.id 
                    join eml_delivery d on f.id=d.id_followup
                    join eml_click o on d.id=o.id_delivery 
                    where c.delete_time is null 
                    and o.create_time > coalesce(c.timeline_end_time, '2000-01-01')
                    group by c.id
                    union
                    -- campaigns with new unsubscribes
                    select c.id
                    from eml_campaign c
                    join eml_followup f on c.id=c.id 
                    join eml_delivery d on f.id=d.id_followup
                    join eml_unsubscribe o on d.id=o.id_delivery 
                    where c.delete_time is null 
                    and o.create_time > coalesce(c.timeline_end_time, '2000-01-01')
                    group by c.id                
                "].map(:id)
            end

            def update_stats
                rows = DB[BlackStack::Emails.query_sents(nil, nil, self.id, nil, nil)].all
                self.stat_sents = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unique_opens(nil, nil, self.id, nil, nil)].all
                self.stat_opens = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unique_clicks(nil, nil, self.id, nil, nil)].all
                self.stat_clicks = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_bounces(nil, nil, self.id, nil, nil)].all
                self.stat_bounces = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_replies(nil, nil, self.id, nil, nil)].all
                self.stat_replies = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_unsubscribes(nil, nil, self.id, nil, nil)].all
                self.stat_unsubscribes = rows.map { |row| row[:n] }.sum
                
                rows = DB[BlackStack::Emails.query_positive_replies(nil, nil, self.id, nil, nil)].all
                self.stat_positive_replies = rows.map { |row| row[:n] }.sum
                
                self.stat_left = self.followups.select { |f| f.status == BlackStack::Emails::Followup::STATUS_ON }.map { |f| f.stat_left }.max || 0

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


        end # class Campaign
    end # Emails
end # BlackStack