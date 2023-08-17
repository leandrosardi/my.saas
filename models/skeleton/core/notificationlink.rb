module BlackStack
    module MySaaS
        class NotificationLink < Sequel::Model(:notification_link)
            many_to_one :notification, :class=>:'BlackStack::MySaaS::Notification', :key=>:id_notification

            # get the tracking url for a specific user
            def tracking_url
                "#{BlackStack::Emails.tracking_url}/api1.0/notifications/click.json?lid=#{self.id.to_guid}"
            end
        end # class NotificationLink
    end # module MySaaS
end # module BlackStack