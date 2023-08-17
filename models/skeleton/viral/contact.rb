require 'sequel'

module BlackStack
    module Viral
        class Contact < Sequel::Model(:vir_contact)
            many_to_one :sharing, :class=>:'BlackStack::Viral::Sharing', :key=>:id_sharing
        end # class Contact
    end # module Viral
end # module BlackStack