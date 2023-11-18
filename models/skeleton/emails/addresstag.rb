module BlackStack
    module Emails
        class AddressTag < Sequel::Model(:eml_address_tag)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address
            many_to_one :tag, :class=>:'BlackStack::Emails::Tag', :key=>:id_tag
        end # class AddressTag
    end # Emails
end # BlackStack