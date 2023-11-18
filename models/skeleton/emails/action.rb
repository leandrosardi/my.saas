module BlackStack
    module Emails
        class Action < Sequel::Model(:eml_action)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            many_to_one :followup, :class=>:'BlackStack::Emails::Followup', :key=>:id_followup
            many_to_one :link, :class=>:'BlackStack::Emails::Link', :key=>:id_link

            # triggers
            TRIGGER_POSITIVE_RESPONSE = 0
            TRIGGER_OPEN = 1 
            TRIGGER_CLICK = 2
            
            # actions
            ACTION_ADD_LEAD_TO_LIST = 0

            # class methods
            def self.triggers
                [TRIGGER_POSITIVE_RESPONSE]
            end

            def self.actions
                [ACTION_ADD_LEAD_TO_LIST]
            end

            def self.trigger_name(trigger)
                case trigger
                when TRIGGER_POSITIVE_RESPONSE
                    return "Positive Response"
                when TRIGGER_OPEN
                    return "Open"
                when TRIGGER_CLICK
                    return "Click"
                else
                    return "Unknown"
                end
            end

            def self.action_name(action)
                case action
                when ACTION_ADD_LEAD_TO_LIST
                    return "Add Lead to List"
                else
                    return "Unknown"
                end
            end

            def self.trigger_color(trigger)
                case trigger
                when TRIGGER_POSITIVE_RESPONSE
                    return "success"
                when TRIGGER_OPEN
                    return "warning"
                when TRIGGER_CLICK
                    return "info"
                else
                    return "gray"
                end
            end

            def self.action_color(action)
                case action
                when ACTION_ADD_LEAD_TO_LIST
                    return "success"
                else
                    return "gray"
                end
            end

            # execution methods
            def perform(l=nil)
                case self.action_type
                when ACTION_ADD_LEAD_TO_LIST
                    self.perform_add_lead_to_list(l)
                end
            end

            def perform_add_lead_to_list(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # building the query
                q = "
                    select distinct r.id_lead
                    from eml_action a
                "

                if !self.id_campaign.to_s.empty?
                    q += "
                        join eml_campaign c on c.id=a.id_campaign
                        join eml_followup f on c.id=f.id_campaign
                    "
                elsif !self.id_followup.to_s.empty?
                    q += "
                        join eml_followup f on f.id=a.id_followup
                    "
                end

                q += "
                    join eml_delivery d on (
                        f.id=d.id_followup and 
                        coalesce(d.is_response,false)=false and 
                        coalesce(d.delivery_success,false)=true
                    )
                    join eml_delivery r on (	
                        d.id_conversation = r.id_conversation and
                        coalesce(r.is_response,false)=true and 
                        coalesce(r.is_bounce,false)=false and 
                        coalesce(r.is_positive,false)=true
                    ) 
                    where a.id='#{self.id}'
                "

                if !self.apply_to_previous_events
                    q += "
                        and r.create_time >= cast('#{self.create_time}' as timestamp)
                    "
                end

                if self.delay_minutes.to_i > 0
                    q += "
                        and r.create_time < cast('#{now}' as timestamp) - interval '#{self.delay_minutes} minutes' 
                    "
                end

                q += "
                    except
                    select distinct o.id_lead
                    from eml_action_log o
                    where o.id_action='#{self.id}'
                "
                
                # executing the query
                DB[q].all { |r|
                    l.logs "adding lead #{r[:id_lead]}... "
                    x = BlackStack::Leads::ExportLead.where(:id_export=>self.id_export, :id_lead=>r[:id_lead]).first
                    if x
                        l.logf "already exists".yellow
                    else
                        x = BlackStack::Leads::ExportLead.new
                        x.id = guid
                        x.create_time = now
                        x.id_export = self.id_export
                        x.id_lead = r[:id_lead]
                        x.save
                        l.logf "done".green
                    end

                    l.logs "tracking the action log... "
                    x = BlackStack::Emails::Actionlog.new
                    x.id = guid
                    x.create_time = now
                    x.id_action = self.id
                    x.id_lead = r[:id_lead]
                    x.save
                    l.logf "done".green
                }
            end

        end # Action
    end # Emails
end # BlackStack