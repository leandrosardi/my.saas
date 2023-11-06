module BlackStack
    module MySaaS
        class Country < Sequel::Model(:country)
            one_to_many :states, :class=>:'BlackStack::MySaaS::State', :key=>:id_country
        end # class Country
    end # module MySaaS
end # module BlackStack