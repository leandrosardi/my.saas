require 'blackstack-deployer'

module BlackStack
    module Extensions
        # This module is to define the folders to add in the storage, for the extension.
        class StorageFolder
            include BlackStack::Extensions::StorageFolderModule
            attr_accessor :name
        end # class StorageFolder
    end # module Extensions
end # module BlackStack