require 'my-ruby-deployer'

module BlackStack
    module Extensions
        # If the extension is an app or api, this module is to define the pages to add in the settings screen, for the extension.
        class SettingScreen
            include BlackStack::Extensions::SettingScreenModule
            attr_accessor :section, :label, :screen, :description
        end # class SettingScreen
    end # module Extensions
end # module BlackStack