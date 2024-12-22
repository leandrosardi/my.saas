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
      def self.add_followup(h={})
        errors = []
        
        # validation: h must be a hash
        errors << "h must be a hash" unless h.is_a?(Hash)
        # validation: h must have 'name'
        errors << "'name' is required" if h['name'].to_s.size==0
        # validation: if 'name' exists, it must be a string
        errors << "'name' must be a string" if h['name'].class!=String
        # validation: if 'name' exists, it cannot be blank
        errors << "'name' cannot be blank" if h['name'].to_s.size==0
        # validation: if 'name' exists, it cannot be present in any of the hashes added @@followups
        errors << "'name' cannot be present in @@followups" if @@followups.map{|x| x['name']}.include?(h['name'])
      
        # validation: 'description' must be nil or string
        errors << "'description' must be nil or string" if h['description'].class!=NilClass && h['description'].class!=String

        # validation: 'notification' is mandatory
        errors << "'notification' is required" if h['notification'].nil?
        # validation: if 'notification' exists, it must be a class
        errors << "'notification' must be a child class of BlackStack::MySaaS::Notification" if !h['notification'].nil? && h['notification'].class!=Class
        # validation: if 'notification' is a class, it must be a child class of BlackStack::MySaaS::Notification
        errors << "'notification' must be a child class of BlackStack::MySaaS::Notification" if h['notification'].class==Class && !h['notification'].ancestors.include?(BlackStack::MySaaS::Notification)
        
        # validation: 'condition' must nil or be a function
        errors << "'condition' must be a function" if h['condition'].class!=NilClass && h['condition'].class!=Proc
        # validation: if 'condition' is a function, it must accept a single argument
        errors << "'condition' must accept a single argument" if h['condition'].class==Proc && h['condition'].arity!=1

        # validation: 'repeat_notification' cannot be nil
        errors << "'repeat_notification' cannot be nil" if h['repeat_notification'].nil?
        # validation: if 'repeat_notification' is not nil, it must be boolean
        errors << "'repeat_notification' must be boolean" if !h['repeat_notification'].nil? && h['repeat_notification'].class!=TrueClass && h['repeat_notification'].class!=FalseClass

        # validation: 'repeat_notification_units' must be nil or integer
        errors << "'repeat_notification_units' must be nil or integer" if h['repeat_notification_units'].class!=NilClass && h['repeat_notification_units'].class!=Integer
        # validation: if 'repeat_notification_units' is integer, it must be greater than 0
        errors << "'repeat_notification_units' must be greater than 0" if h['repeat_notification_units'].class==Integer && h['repeat_notification_units']<=0

        # validation: 'repeat_notification_period' cannot be nil
        errors << "'repeat_notification_period' cannot be nil" if h['repeat_notification_period'].nil?
        # validation: if 'repeat_notification_period' is not nil, it must be a string
        errors << "'repeat_notification_period' must be a string" if !h['repeat_notification_period'].nil? && h['repeat_notification_period'].class!=String
        # validation: if 'repeat_notification_period' is a string, it must be one of the following: 'minutes', 'hours', 'days', 'weeks', 'months', 'years'
        errors << "'repeat_notification_period' must be one of the following: 'minutes', 'hours', 'days', 'weeks', 'months', 'years'" if !h['repeat_notification_period'].nil? && !['minutes', 'hours', 'days', 'weeks', 'months', 'years'].include?(h['repeat_notification_period'])

        # validation: 'repeat_times' cannot be nil
        errors << "'repeat_times' cannot be nil" if h['repeat_times'].nil?
        # validation: if 'repeat_times' is not nil, it must be integer
        errors << "'repeat_times' must be integer" if !h['repeat_times'].nil? && h['repeat_times'].class!=Integer
        # validation: if 'repeat_times' is integer, it must be greater than -2
        errors << "'repeat_times' must be greater than -2" if h['repeat_times'].class==Integer && h['repeat_times']<=-2

        # validation: if 'track_opens' exists, it must be boolean
        errors << "'track_opens' must be boolean" if !h['track_opens'].nil? && h['track_opens'].class!=TrueClass && h['track_opens'].class!=FalseClass

        # validation: if 'track_clicks' exists, it must be boolean
        errors << "'track_clicks' must be boolean" if !h['track_clicks'].nil? && h['track_clicks'].class!=TrueClass && h['track_clicks'].class!=FalseClass

        # if any error happened, raise exception
        raise errors.join("\n") if errors.size>0

        # add followup
        @@followups << h
      end # add_followup

      # static methods regarding followups
      module FollowUps
        # return an array with all the followups pending to deliver for a specific user
        # u: the user to test.
        # name: the name of the followup to test. If it is nil, all followups will be tested.
        # l: the log object to use. If it is nil, a dummy one will be created.
        def self.user_pendings(u, name=nil, l=nil)
          ret = []
          # if l.nil? then create a dummy logger
          l = BlackStack::DummyLogger.new(nil) if l.nil?
          # get the list of followups
          followups = BlackStack::Notifications.followups
          followups.select! { |w| w['name']==name } if !name.nil?
          # iterate the array of followups of BlackStack::Notifications
          followups.each do |w|
            l.logs "Testing followup #{w['name']} for #{u.email}... "
            # call the method w['condition']
            if w['condition'].nil? || w['condition'].call(u)
              ret << w
              l.logf "MET!"
            else
              # if the condition is false, log it
              l.logf "not met"
            end
          end # end of iterating the array of followups of BlackStack::Notifications
          # return the array of followups pending to deliver for a specific user
          ret
        end # def self.user_pendings

        # deliver test all the followups pending for a specific user
        # u: the user to test.
        # to: the email to deliver the test email.
        # name: the name of the followup to test. If it is nil, all followups will be tested.
        # l: the log object to use. If it is nil, a dummy one will be created.
        def self.test(u, to, name=nil, l=nil)
          # if l.nil? then create a dummy logger
          l = BlackStack::DummyLogger.new(nil) if l.nil?
          # get the list of followups
          l.logs "Get the list of followups..."
          followups = BlackStack::Notifications::FollowUps.user_pendings(u, name, l)
          l.logf "done (#{followups.size.to_s})"
          # iterate the array of followups
          followups.each do |w|
            # deliver the followup
            l.logs "Delivering followup #{w['name']}..."
            n = w['notification'].new(u)
            n.email_to = to # force the recipient to the test email
            n.save
            n.do
            l.done
          end
        end # def self.test

        # deliver notification all the followups pending for a specific user
        # u: the user to test.
        # name: the name of the followup to test. If it is nil, all followups will be tested.
        # l: the log object to use. If it is nil, a dummy one will be created.
        def self.deliver(u, name=nil, l=nil)
          # if l.nil? then create a dummy logger
          l = BlackStack::DummyLogger.new(nil) if l.nil?
          # get the list of followups
          l.logs "Get the list of followups..."
          followups = BlackStack::Notifications::FollowUps.user_pendings(u, name, l)
          l.logf "done (#{followups.size.to_s})"
          # iterate the array of followups
          followups.each do |w|
            # deliver the followup
            l.logs "Delivering followup #{w['name']}..."
            w['notification'].new(u).save.do
            l.done
          end
        end # def self.deliver
      end # module FollowUps

    end # module Notifications
end # module BlackStack