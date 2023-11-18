module BlackStack
    module Emails
        class Test < Sequel::Model(:eml_test)
            many_to_one :address, :class=>:'BlackStack::Emails::Address', :key=>:id_address
            many_to_one :followup, :class=>:'BlackStack::Emails::Followup', :key=>:id_followup

        end # class Test
    end # Emails
end # BlackStack