module BlackStack
    module Extensions
        # This module is to define the folders to add in the storage, for the extension.
        module StorageFolderModule
            # return an array of strings with the errors found on the hash descriptor
            def self.validate_descriptor(h)
                errors = []

                # validate: h must be a hash
                errors << "storage_folder descriptor must be a hash" unless h.is_a?(Hash)

                # only if h is a hash
                if h.is_a?(Hash)
                    # validate: the key :name is required
                    errors << ":name is required" if h[:name].to_s.size==0

                    # validate: the value of h[:name] must be a string
                    errors << ":name must be a string" if !h[:name].is_a?(String)
                end

                # return
                errors
            end

            # map a hash descriptor to the attributes of the object
            def initialize(h)
                errors = BlackStack::Extensions::StorageFolderModule::validate_descriptor(h)
                # if there are errors, raise an exception
                raise "Invalid descriptor: #{errors.join(', ')}" if errors.size>0
                # map the parameters
                self.name = h[:name]
            end # set

            # get a hash descriptor of the object
            def to_hash
                {
                    :name => self.name,
                }
            end # to_hash
        end # module StorageFolderModule
    end # module Extensions
end # module BlackStack