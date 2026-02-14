require 'lib/emails'

module BlackStack
    module Notifications
      # notifications setup
      @@logo_url = nil
      @@signature_picture_url = nil
      @@signature_name = nil
      @@signature_position = nil
      @@notifications = []
      @@followups = []

      # getters and setters
      def self.logo_url
        @@logo_url
      end
      def self.signature_picture_url
        @@signature_picture_url
      end
      def self.signature_name
        @@signature_name
      end
      def self.signature_position
        @@signature_position
      end
      def self.followups
        @@followups
      end
      def self.set(h={})
        errors = []
          
        # validate: h must be a hash
        errors << "h must be a hash" unless h.is_a?(Hash)

        # validate: logo_url is required
        errors << ":logo_url is required" if h[:logo_url].to_s.size==0

        # validate: signature_picture_url is required
        errors << ":signature_picture_url is required" if h[:signature_picture_url].to_s.size==0

        # validate: signature_name is required
        errors << ":signature_name is required" if h[:signature_name].to_s.size==0

        # validate: signature_position is required
        errors << ":signature_position is required" if h[:signature_position].to_s.size==0

        # validate: logo_url is a valid url
        errors << ":logo_url must be a valid url" unless h[:logo_url].url?

        # validate: signature_picture_url is a valid url
        errors << ":signature_picture_url must be a valid url" unless h[:signature_picture_url].url?

        # validate: signature_name is a string
        errors << ":signature_name must be a string" if h[:signature_name].class!=String

        # validate: signature_position is a string
        errors << ":signature_position must be a string" if h[:signature_position].class!=String

        # if errors, raise exception
        raise errors.join("\n") if errors.size>0

        # set values
        @@logo_url = h[:logo_url]
        @@signature_picture_url = h[:signature_picture_url]
        @@signature_name = h[:signature_name]
        @@signature_position = h[:signature_position]
      end # def self.set

      # add a followup
      def self.add(h)
        errors = []
        # TODO: Validate hash descriptor.
        # if any error happened, raise exception
        raise errors.join("\n") if errors.size>0
        # add followup
        @@followups << h
      end # add

      # deliver pending notification of a followup
      # h: hash descriptor of the followup
      # l: the log object to use. If it is nil, a dummy one will be created.
      def self.deliver(h, logger:nil)
        # if l.nil? then create a dummy logger
        l = logger || BlackStack::DummyLogger.new(nil)
        # get the list of followups
        l.logs "Processing followup #{h[:name].blue}... "
        rows = h[:objects].call().all
        rows.each { |o|
          l.logs "User #{o[:id].blue}... "
          u = h[:user].call(o)
          subject = h[:subject].call(o)
          body = h[:body].call(o)
          # sometimes, notifications are not for delivering emails, but for other things (like push a user to the CRM)
          # https://github.com/connection-sphere/docs/issues/632
          #
          n = BlackStack::MySaaS::Notification.new(o, h)
          if subject && body
            n.deliver 
            n.save
          end
          n.done # mark the notification as done
          l.done
        }
        l.done(details: "#{rows.size.to_s.blue} users")
      end # def self.deliver

      # deliver pending notification of all followups
      # l: the log object to use. If it is nil, a dummy one will be created.
      def self.run(logger:nil)
        l = logger || BlackStack::DummyLogger.new(nil)
        @@followups.each { |h|
          BlackStack::Notifications::deliver(h, logger:l)            
        }
      end

    end # module Notifications
end # module BlackStack