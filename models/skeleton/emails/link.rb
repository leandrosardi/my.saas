module BlackStack
    module Emails
        class Link < Sequel::Model(:eml_link)
            many_to_one :campaign, :class=>:'BlackStack::Emails::Campaign', :key=>:id_campaign

            # return the url of the tracking link
            def tracking_url(delivery)
                ret = nil
                errors = []
                # validation: self.id is not nil and it is a valid guid
                errors << "id is nil" if self.id.nil? || !self.id.guid?
                # validation: self.address is not nil
                errors << "address is nil" if delivery.address.nil?
                # if any error happened, raise an exception
                raise errors.join(", ") if errors.size > 0
                # return
                return "#{delivery.address.tracking_url}/api1.0/emails/click.json?lid=#{self.id.to_guid}&did=#{delivery.id.to_guid}"
            end # def tracking_url
        end # class Link
    end # Emails
end # BlackStack