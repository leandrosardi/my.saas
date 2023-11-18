module BlackStack
    module Emails
        class Outreach < Sequel::Model(:eml_outreach)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign
            many_to_one :tag, :class=>:'BlackStack::Emails::Tag', :key=>:id_tag
            
        end # class Outreach
    end # Emails
end # BlackStack