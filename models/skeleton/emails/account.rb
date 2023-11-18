module BlackStack
    module Emails
        # inherit from BlackStack::MySaaS::Account
        class Account < BlackStack::MySaaS::Account

            # Daily stop-limit emails deliveries.
            # By now, each account can deliver up to 10000 emails per day.
            # Reference: https://github.com/leandrosardi/cs/issues/65
            def stop_limit
                10000
            end

            def stop_left
                uids = self.users.map { |u| u.id }
                q = "
                    select count(distinct d.id_lead) as n
                    from eml_delivery d
                    join eml_followup f on (f.id=d.id_followup and f.id_user in ('#{uids.join("','")}'))
                    where ( 
                        (d.delivery_end_time >= CAST('#{now()}' AS TIMESTAMP) - INTERVAL '1 day' and d.delivery_success=true)
                        or
                        d.delivery_end_time is null
                    )
                    and d.is_response=false
                "
                row = DB[q].first
                return 0 if row.nil?
                spent = row[:n].to_i
                self.stop_limit - spent
            end

            # return array of Tag objects, each one linked to this account thru the table user.
            def tags
                self.users.map{ |u|
                    BlackStack::Emails::User.where(:id=>u.id).first.tags
                }.flatten
            end

            # return array of MTA objects, each one linked to this account thru the table user.
            def mtas
                self.users.map{ |u|
                    BlackStack::Emails::User.where(:id=>u.id).first.mtas
                }.flatten
            end

            def addresses
                self.users.map { |u| 
                    BlackStack::Emails::User.where(:id=>u.id).first.addresses.select { |o| 
                        o.delete_time.nil? && o.enabled 
                    } 
                }.flatten
            end # def addresses

            def campaigns
                self.users.map { |u| 
                    BlackStack::Emails::User.where(:id=>u.id).first.campaigns.select { |o|
                        o.delete_time.nil?
                    }
                }.flatten
            end # def campaigns
        end # class Account
    end # module Emails
end # module BlackStack