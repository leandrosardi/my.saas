module BlackStack
    module MySaaS
        class NotificationClick < Sequel::Model(:notification_click)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :link, :class=>:'BlackStack::MySaaS::NotificationLink', :key=>:id_link
        end # class NotificationClick
    end # module MySaaS
end # module BlackStack