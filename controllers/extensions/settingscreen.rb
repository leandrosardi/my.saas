module BlackStack
    module Extensions
        # If the extension is an app or api, this module is to define the pages to add in the settings screen, for the extension.
        module SettingScreenModule
            # return an array of strings with the errors found on the hash descriptor
            def self.validate_descriptor(h)
                errors = []

                # validate: h must be a hash
                errors << "setting_screen must be a hash" unless h.is_a?(Hash)

                # only if h is a hash
                if h.is_a?(Hash)
                    # validate: the key :section is required
                    errors << ":section is required" if h[:section].to_s.size==0

                    # validate: the value of h[:section] must be a string
                    errors << ":section must be a string" if !h[:section].is_a?(String)

                    # validate: the key :label is required
                    errors << ":label is required" if h[:label].to_s.size==0

                    # validate: the value of h[:label] must be a string
                    errors << ":label must be a string" if !h[:label].is_a?(String)

                    # validate: the key :screen is required
                    errors << ":screen is required" if h[:screen].to_s.size==0

                    # validate: the value of h[:screen] must be a symbol
                    errors << ":screen must be a symbol" if !h[:screen].is_a?(Symbol)
                end

                # return
                errors
            end # validate_descriptor

            # map a hash descriptor to the attributes of the object
            def initialize(h)
                errors = BlackStack::Extensions::SettingScreenModule::validate_descriptor(h)
                # if there are errors, raise an exception
                raise "Invalid descriptor: #{errors.join(', ')}" if errors.size>0
                # map the parameters
                self.section = h[:section]
                self.label = h[:label]
                self.screen = h[:screen].to_s
            end # set

            # get a hash descriptor of the object
            def to_hash
                {
                    :section => self.section,
                    :label => self.label,
                    :screen => self.screen.to_sym,
                }
            end # to_hash
        end # module SettingScreenModule
    end # module Extensions
end # module BlackStack