require 'sequel'

module BlackStack
    module Viral
        class Sharing < Sequel::Model(:vir_sharing)
            one_to_many :contacts, :class=>:'BlackStack::Viral::Contact', :key=>:id_sharing
        end # class Sharing
    end # module Viral
end # module BlackStack