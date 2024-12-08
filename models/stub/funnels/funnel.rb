module BlackStack
  module Funnel
    @@ga = nil # GTM code
    @@recaptcha2_site_key = nil
    @@recaptcha2_secret_key = nil
    @@funnels = []

    # Google Analytics
    def self.set(h)
      @@ga = h[:ga]
      @@recaptcha2_site_key = h[:recaptcha2_site_key]
      @@recaptcha2_secret_key = h[:recaptcha2_secret_key]
    end

    def self.recaptcha2_site_key
      @@recaptcha2_site_key
    end

    def self.recaptcha2_secret_key
      @@recaptcha2_secret_key
    end

    def self.ga_head_code
      return "<!-- NO GA CONFIGURED -->" if @@ga.nil?
      "<!-- Google tag (gtag.js) -->
      <script async src=\"https://www.googletagmanager.com/gtag/js?id=#{@@ga}\"></script>
      <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
      
        gtag('config', 'G-L6ZL9C2LRH');
      </script>"
    end

    # Funnels
    def self.add(h)
      @@funnels << h
    end

    def self.url_root(login, name)
      h = @@funnels.find { |h| h[:name] == name }
      h[:url_root].call(login)
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
  