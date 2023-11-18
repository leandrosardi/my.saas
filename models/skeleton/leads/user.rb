module BlackStack
    module Leads
        class User < BlackStack::MySaaS::User
            one_to_many :fl_exports, :class=>:'BlackStack::Leads::Export', :key=>:id_user
        end # class User
    end # module Leads
end # module BlackStack