require 'controllers/extensions/leftbaricon'
require 'controllers/extensions/dependency'
require 'controllers/extensions/settingscreen'
require 'controllers/extensions/storagefolder'
require 'controllers/extensions/extension'

module BlackStack
    module Extensions
        # array of Extension objects
        @@extensions = []

        # getters and setters
        def self.extensions
            @@extensions
        end

        # Create an extension object.
        # Add it to the array of extensions
        # Return the object
        def self.add(h)
            e = BlackStack::Extensions::Extension::new(h)
            @@extensions << e
            e
        end # set

        # Use this method to add an extension to your SaaS
        # This method do a require of the extension.rb file, where is a call to BlackStack::Extensions.add(h)
        def self.append(ext_name, custom_config = {})
            # validate: name must be a symbol
            raise "name must be a symbol" if !ext_name.is_a?(Symbol)
            # require the extension definition. it is usually added in the `config.rb` file.
            require "extensions/#{ext_name.to_s}/extension"            
            # require the object, because sometimes they are needed in the `config.rb` file.
            require "extensions/#{ext_name.to_s}/main"
            # add updates
            BlackStack::Extensions.extensions.select { |o| o.name.upcase == ext_name.to_s.upcase }.first.update(custom_config)
        end # require

        # Return true if an extension with the name is loaded
        def self.exists?(name)
            @@extensions.each do |e|
                return true if e.name.to_s == name.to_s
            end
            false
        end # exists?

        # adding storage sub-folders
        # DEPRECATED
=begin
        def self.add_storage_subfolders    
            @@extensions.each do |e|
                e.storage_folders.each do |f|
                    BlackStack::Storage::add_storage_sub_folders([f.name])
                end
            end
        end
=end
    end # module Extensions
end # module BlackStack
