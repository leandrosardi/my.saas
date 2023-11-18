module BlackStack
    module Emails
        # inherit from BlackStack::MySaaS::User
        class User < BlackStack::MySaaS::User
            one_to_many :mtas, :class=>:'BlackStack::Emails::Mta', :key=>:id_user
            one_to_many :addresses, :class=>:'BlackStack::Emails::Address', :key=>:id_user
            one_to_many :campaigns, :class=>:'BlackStack::Emails::Campaign', :key=>:id_user
            one_to_many :tags, :class=>:'BlackStack::Emails::Tag', :key=>:id_user
            one_to_many :addresstags, :class=>:'BlackStack::Emails::AddressTag', :key=>:id_user
        end # class User
    end # module Emails
end # module BlackStack