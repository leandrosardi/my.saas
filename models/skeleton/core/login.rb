require 'sequel'

module BlackStack
    module MySaaS
        class Login < Sequel::Model(:login)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :real_user, :class=>:'BlackStack::MySaaS::User', :key=>:id_real_user

            # return the user or the real user (admin) logged into this login
            def whois
                self.real_user || self.user
            end
        end # class Login
    end # module MySaaS
end # module BlackStack