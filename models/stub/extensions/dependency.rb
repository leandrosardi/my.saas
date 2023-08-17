require 'blackstack-deployer'

module BlackStack
    module Extensions
        # This module is to define which other extensions are required for the extension.
        class Dependency
            include BlackStack::Extensions::DependencyModule
            attr_accessor :extension, :version
        end # class Dependency
    end # module Extensions
end # module BlackStack