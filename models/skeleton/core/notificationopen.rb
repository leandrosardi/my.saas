module BlackStack
    module MySaaS
        class NotificationOpen < Sequel::Model(:notification_open)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :notification, :class=>:'BlackStack::MySaaS::Notification', :key=>:id_notification
        end # class NotificationOpen
    end # module MySaaS
end # module BlackStack