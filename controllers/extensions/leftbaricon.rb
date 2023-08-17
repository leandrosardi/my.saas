module BlackStack
    module Extensions
        # If the extension is an app, this module is to define the icons in the leftbar of the extension. 
        module LeftBarIconModule
            # return an arrayn of strings with the errors found on the hash descriptor
            def self.validate_descriptor(h)
                errors = []

                # only if h is a hash
                if h.is_a?(Hash)
                    # the key :label must exits
                    errors << ":label is required" if h[:label].to_s.size==0
                    
                    # the value of h[:label] must be a string
                    errors << ":label must be a string" if !h[:label].is_a?(String)

                    # the key :icon must exits
                    errors << ":icon is required" if h[:icon].to_s.size==0

                    # the value of h[:icon] must be a symbol
                    errors << ":icon must be a symbol" if !h[:icon].is_a?(Symbol)

                    # the key :screen must exits
                    errors << ":screen is required" if h[:screen].to_s.size==0

                    # the value of h[:screen] must be a symbol
                    errors << ":screen must be a symbol" if !h[:screen].is_a?(Symbol)
                end
                
                # return
                errors
            end # validate_descriptor

            # map a hash descriptor to the attributes of the object
            def initialize(h)
                errors = BlackStack::Extensions::LeftBarIconModule::validate_descriptor(h)
                # if there are errors, raise an exception
                raise "Invalid descriptor: #{errors.join(', ')}" if errors.size>0
                # map the parameters
                self.label = h[:label]
                self.icon = h[:icon].to_s
                self.screen = h[:screen].to_s
                self.badge_color = h[:badge_color].to_s
                self.badge_icon = h[:badge_icon].to_s
                self.badge_text = h[:badge_text].to_s
                self.badge_title = h[:badge_title].to_s
            end # set

            # get a hash descriptor of the object
            def to_hash
                {
                    :label => self.label,
                    :icon => self.icon.to_sym,
                    :screen => self.screen.to_sym,
                    :badge_color => self.badge_color.to_sym,
                    :badge_icon => self.badge_icon.to_sym,
                    :badge_text => self.badge_text,
                    :badge_title => self.badge_title,
                }
            end # to_hash
        end # module LeftBarIconModule
    end # module Extensions
end # module BlackStack