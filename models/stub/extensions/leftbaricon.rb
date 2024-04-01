require 'my-ruby-deployer'

module BlackStack
    module Extensions
        # If the extension is an app, this module is to define the icons in the leftbar of the extension. 
        class LeftBarIcon
            include BlackStack::Extensions::LeftBarIconModule
            attr_accessor :label, :icon, :screen, :items, :badge_color, :badge_icon, :badge_text, :badge_title
        end # class LeftBarIcon
    end # module Extensions
end # module BlackStack