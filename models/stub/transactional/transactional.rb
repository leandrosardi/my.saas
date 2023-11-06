module BlackStack
  module Notifications 
    @@notifs = []

    def self.define(a)
      # TODO: Validate array of descriptors
      @@notifs = a
    end

    def self.add(h)
      # TODO: Validate hash descriptor
      @@notifs << h
    end

    def self.notifs
      @@notifs
    end

    def self.run(l=nil)
      l = BlackStack::DummyLogger.new(nil) if l.nil?
      @@notifs.each { |h|
        l.logs "Loading objects for #{h[:name].to_s.blue}... "
        ds = h[:objects].call().limit(100)
        l.logf 'done'.green + " (#{ds.count.to_s.blue})"
        ds.all { |o|
            l.logs "Sending #{h[:name].to_s.blue} to #{h[:email_to].call(o).to_s.blue}... "
            n = BlackStack::MySaaS::Notification.new(o, h)
            n.save
            n.deliver
            l.logf 'done'.green
        }
      }
    end # run
  end # module Notifications
end # module BlackStack