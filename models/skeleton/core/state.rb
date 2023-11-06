module BlackStack
    module MySaaS
        class State < Sequel::Model(:state)
            many_to_one :country, :class=>:'BlackStack::MySaaS::Country', :key=>:id_country
        end # class State
    end # module MySaaS
end # module BlackStack