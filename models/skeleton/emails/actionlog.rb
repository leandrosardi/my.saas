module BlackStack
    module Emails
        class Actionlog < Sequel::Model(:eml_action_log)
            many_to_one :action, :class=>:'BlackStack::Emails::Action', :key=>:id_action
            many_to_one :lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead
        end # Actionlog
    end # Emails
end # BlackStack