module BlackStack
  module Funnel
    @@funnels = []

    def self.add(h)
      @@funnels << h
    end

    def self.url_plans(login, name)
      h = @@funnels.find { |h| h[:name] == name }
      h[:url_plans].call(login)
    end

    def self.url_after_signup(login, name)
      h = @@funnels.find { |h| h[:name] == name }
      h[:url_after_signup].call(login)
    end

    def self.url_after_login(login, name)
      h = @@funnels.find { |h| h[:name] == name }
      h[:url_after_login].call(login)
    end

    def self.url_to_go_free(login, name)
      h = @@funnels.find { |h| h[:name] == name }
      h[:url_to_go_free].call(login)
    end
  end # Funnel
end # BlackStack
  