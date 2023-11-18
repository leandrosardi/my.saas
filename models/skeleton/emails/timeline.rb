module BlackStack
    module Emails
        class Timeline < Sequel::Model(:eml_timeline)
            many_to_one :address, :class=>BlackStack::Emails::Address
            many_to_one :followup, :class=>BlackStack::Emails::Followup
            many_to_one :campaign, :class=>BlackStack::Emails::Campaign

            # -------------------------------------------------------------------------------------
            # Statistic Methods
            # -------------------------------------------------------------------------------------
            
            # return query to get the number of emails sent, by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.stats(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        sum(t.stat_sents) as sents,
                        sum(t.stat_replies) as replies,
                        sum(t.stat_positive_replies) as positive_replies,
                        sum(t.stat_opens) as opens,
                        sum(t.stat_unique_opens) as unique_opens,
                        sum(t.stat_clicks) as clicks,
                        sum(t.stat_unique_clicks) as unique_clicks,
                        sum(t.stat_bounces) as bounces,
                        sum(t.stat_unsubscribes) as unsubscribes
                    from eml_timeline t
                    where 1=1
                " 
                q += " and t.id_account='#{id_account}'" if id_account
                q += " and t.id_campaign='#{id_campaign}'" if id_campaign
                q += " and t.id_followup='#{id_followup}'" if id_followup
                q += " and t.id_address='#{id_address}'" if id_address
                
                q += "and cast(t.year as varchar(4))||'-'||cast(t.month as varchar(2))||'-'||cast(t.day as varchar(2))||' '||cast(t.hour as varchar(2))||'-'||':00:00' > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00' "

                DB[q].first
            end # def self.sents

            # return query to get the number of emails received, by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_replies(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', r.create_time) as yy,
                        extract('month', r.create_time) as mm,
                        extract('day', r.create_time) as dd,
                        extract('hour', r.create_time) as hh,
                        count(distinct r.id) as n
                    from eml_delivery d
                    join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce)=false)
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where coalesce(d.is_response,false) = false
                    and coalesce(d.delivery_success,false) = true
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and r.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'

                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', r.create_time),
                        extract('month', r.create_time),
                        extract('day', r.create_time),
                        extract('hour', r.create_time)
                "
            end

            # return query to get the number of emails received and marked as positives, by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_positive_replies(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', r.create_time) as yy,
                        extract('month', r.create_time) as mm,
                        extract('day', r.create_time) as dd,
                        extract('hour', r.create_time) as hh,
                        count(distinct r.id) as n
                    from eml_delivery d
                    join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce,false)=false and coalesce(r.is_positive,false)=true)
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where coalesce(d.is_response,false) = false
                    and coalesce(d.delivery_success,false) = true
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and r.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'

                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', r.create_time),
                        extract('month', r.create_time),
                        extract('day', r.create_time),
                        extract('hour', r.create_time)
                "
            end

            # return query to get the number of (non-unique) opens by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_opens(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', o.create_time) as yy,
                        extract('month', o.create_time) as mm,
                        extract('day', o.create_time) as dd,
                        extract('hour', o.create_time) as hh,
                        count(distinct o.id) as n
                    from eml_delivery d
                    join eml_open o on d.id=o.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where 1=1
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                
                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', o.create_time),
                        extract('month', o.create_time),
                        extract('day', o.create_time),
                        extract('hour', o.create_time)
                "
            end

            # return query to get the number of (unique) opens by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_unique_opens(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        v.id_account,
                        v.id_campaign,
                        v.id_followup,
                        v.id_address,
                        v.yy,
                        v.mm,
                        v.dd,
                        v.hh,
                        count(*) as n
                    from (
                        select 
                            u.id_account,
                            f.id_campaign, 
                            d.id_followup, 
                            d.id_address,
                            extract('year', min(o.create_time)) as yy,
                            extract('month', min(o.create_time)) as mm,
                            extract('day', min(o.create_time)) as dd,
                            extract('hour', min(o.create_time)) as hh,
                            o.id_delivery
                        from eml_delivery d
                        join eml_open o on d.id=o.id_delivery
                        join eml_followup f on f.id=d.id_followup
                        join \"user\" u on u.id=f.id_user
                        where o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                        group by
                            f.id_campaign, 
                            d.id_followup, 
                            d.id_address,
                            u.id_account,
                            o.id_delivery
                    ) v
                    where 1=1
                    "

                    q += " and v.id_account='#{id_account}'" if id_account
                    q += " and v.id_campaign='#{id_campaign}'" if id_campaign
                    q += " and v.id_followup='#{id_followup}'" if id_followup
                    q += " and v.id_address='#{id_address}'" if id_address    

                    q += "
                    group by 
                        v.id_account,
                        v.id_campaign,
                        v.id_followup,
                        v.id_address,
                        v.yy,
                        v.mm,
                        v.dd,
                        v.hh
                    "            
            end

            # return query to get the number of (non unique) clicks by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_clicks(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', o.create_time) as yy,
                        extract('month', o.create_time) as mm,
                        extract('day', o.create_time) as dd,
                        extract('hour', o.create_time) as hh,
                        count(distinct o.id) as n
                    from eml_delivery d
                    join eml_click o on d.id=o.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where 1=1
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'

                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', o.create_time),
                        extract('month', o.create_time),
                        extract('day', o.create_time),
                        extract('hour', o.create_time)
                "
            end

            # return query to get the number of (unique) clicks by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_unique_clicks(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        v.id_account,
                        v.id_campaign,
                        v.id_followup,
                        v.id_address,
                        v.yy,
                        v.mm,
                        v.dd,
                        v.hh,
                        count(*) as n
                    from (
                        select 
                            u.id_account,
                            f.id_campaign, 
                            d.id_followup, 
                            d.id_address,
                            extract('year', min(o.create_time)) as yy,
                            extract('month', min(o.create_time)) as mm,
                            extract('day', min(o.create_time)) as dd,
                            extract('hour', min(o.create_time)) as hh,
                            o.id_delivery
                        from eml_delivery d
                        join eml_click o on d.id=o.id_delivery
                        join eml_followup f on f.id=d.id_followup
                        join \"user\" u on u.id=f.id_user
                        where r.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'
                        group by
                            f.id_campaign, 
                            d.id_followup, 
                            d.id_address,
                            u.id_account,
                            o.id_delivery
                    ) v
                    where 1=1
                    "

                    q += " and v.id_account='#{id_account}'" if id_account
                    q += " and v.id_campaign='#{id_campaign}'" if id_campaign
                    q += " and v.id_followup='#{id_followup}'" if id_followup
                    q += " and v.id_address='#{id_address}'" if id_address    

                    q += "
                    group by 
                        v.id_account,
                        v.id_campaign,
                        v.id_followup,
                        v.id_address,
                        v.yy,
                        v.mm,
                        v.dd,
                        v.hh
                    "            
            end

            # return query to get the number of bounces by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_bounces(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', r.create_time) as yy,
                        extract('month', r.create_time) as mm,
                        extract('day', r.create_time) as dd,
                        extract('hour', r.create_time) as hh,
                        count(distinct r.id) as n
                    from eml_delivery d
                    join eml_delivery r on (d.id_conversation=r.id_conversation and coalesce(r.is_response,false)=true and coalesce(r.is_bounce,false)=true)
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where coalesce(d.is_response,false) = false
                    and coalesce(d.delivery_success,false) = true
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and r.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'

                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', r.create_time),
                        extract('month', r.create_time),
                        extract('day', r.create_time),
                        extract('hour', r.create_time)
                "
            end

            # return query to get the number of unsubscribes by hour, from a given time
            # 
            # from_time: it is considered at hourly level. Minutes, seconds and milliseconds are set to 0. 
            # id_account: if nil, all accounts are considered
            # id_campaign: if nil, all campaigns are considered
            # id_followup: if nil, all followups are considered
            # id_address: if nil, all addresses are considered
            # 
            def self.query_unsubscribes(from_time=nil, id_account=nil, id_campaign=nil, id_followup=nil, id_address=nil)
                from_time = Time.new(2000, 1, 1) if from_time.nil?
                q = "
                    select 
                        gen_random_uuid() as id,
                        cast('#{now}' as timestamp) as create_time,
                        u.id_account,
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        extract('year', o.create_time) as yy,
                        extract('month', o.create_time) as mm,
                        extract('day', o.create_time) as dd,
                        extract('hour', o.create_time) as hh,
                        count(distinct o.id) as n
                    from eml_delivery d
                    join eml_unsubscribe o on d.id=o.id_delivery
                    join eml_followup f on f.id=d.id_followup
                    join \"user\" u on u.id=f.id_user
                    where 1=1
                "

                q += " and u.id_account='#{id_account}'" if id_account
                q += " and f.id_campaign='#{id_campaign}'" if id_campaign
                q += " and f.id='#{id_followup}'" if id_followup
                q += " and d.id_address='#{id_address}'" if id_address

                q += " 
                    and o.create_time > '#{from_time.year}-#{from_time.month}-#{from_time.day} #{from_time.hour}:00:00'

                    group by
                        f.id_campaign, 
                        d.id_followup, 
                        d.id_address,
                        u.id_account,
                        extract('year', o.create_time),
                        extract('month', o.create_time),
                        extract('day', o.create_time),
                        extract('hour', o.create_time)
                "
            end


        end # class Timeline
    end # module Emails
end # module BlackStack