module BlackStack
    module Emails
        class Unsubscribe < Sequel::Model(:eml_unsubscribe)
            many_to_one :delivery, :class=>:'BlackStack::Emails::Delivery', :key=>:id_delivery

            def push_to_micro_emails_timeline(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                o = self

                l.logs "Get account... "
                a = o.delivery.followup.user.account
                l.logf a.id.blue
            
                l.logs "Assign micro-service... "
                n = BlackStack::Workmesh.assigned_node(a, :'micro.emails.timeline')
                n = BlackStack::Workmesh.assign(a, :'micro.emails.timeline') if !n
                l.logf n.name.blue
            
                l.logs "Push unsubscribe to micro-service... "
                BlackStack::Workmesh.service(:'micro.emails.timeline').protocol('push_unsubscribe').push(o, n)
                l.logf "done".green
            end

            # increment the unsubscribe count for the regarding campaign in the timeline snapshot
            def after_create
                super
                self.delivery.track('unsubscribe')
                # write history in eml_log
                self.delivery.track('unsubscribe')
                # request to push delivery to micro.emails.timeline
                self.delivery.reset_push_to_micro_emails_timeline
            end

            def to_hash
                {
                    'id' => self.id,
                    'id_delivery' => self.id_delivery,
                    'create_time' => self.create_time,
                }
            end

        end # class Unsubscribe
    end # Emails
end # BlackStack