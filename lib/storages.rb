module BlackStack
        module Storage
            # accounts storage parameters
            @@storage_folder = './public/clients'
            @@storage_default_max_allowed_kilobytes = 15*1024 # 15MB
            @@storage_sub_folders = []

            # accounts storage getters and setters
            def self.storage_default_max_allowed_kilobytes()
                @@storage_default_max_allowed_kilobytes
            end
            def self.storage_folder()
                @@storage_folder
            end
            def self.storage_sub_folders()
                @@storage_sub_folders
            end    
            def self.set_storage_folder(path)
                @@storage_folder = path
            end
            def self.set_storage_sub_folders(a)
                # validate: the parameter a must be be an array of strings
                raise 'The parameter a must be an array of strings' if a.class != Array || a.any? { |e| e.class != String }
                @@storage_sub_folders = a
            end
            def self.add_storage_sub_folders(a)
                # validate: the parameter a must be be an array of strings
                raise 'The parameter a must be an array of strings' if a.class != Array || a.any? { |e| e.class != String }
                @@storage_sub_folders += a
            end
            def self.set_storage(h)
                # validate: the parameter h is requred
                raise "The parameter h is required." if h.nil?

                # validate: the parameter h must be a hash
                raise "The parameter h must be a hash" unless h.is_a?(Hash)

                # validate: the :storage_folder key exists
                raise 'The :storage_folder key is required' if h[:storage_folder].nil?

                # validate: the :storage_default_max_allowed_kilobytes key exists
                raise 'The :storage_default_max_allowed_kilobytes key is required' if h[:storage_default_max_allowed_kilobytes].nil?

                # validate: the :storage_sub_folders key exists
                raise 'The :storage_sub_folders key is required' if h[:storage_sub_folders].nil?

                # validate: the :storage_folder key is a string
                raise 'The :storage_folder key must be a string' if h[:storage_folder].class != String

                # validate: the :storage_max_allowed_kilobytes key is an integer, and is greater than 0
                raise 'The :storage_default_max_allowed_kilobytes key must be an integer, and greater than 0' if h[:storage_default_max_allowed_kilobytes].class != Fixnum || h[:storage_default_max_allowed_kilobytes] <= 0

                # validate: the :storage_sub_folders key is an array of strings
                raise 'The :storage_sub_folders key must be an array of strings' if h[:storage_sub_folders].class != Array || h[:storage_sub_folders].any? { |e| e.class != String }

                # map all the parameters
                @@storage_folder = h[:storage_folder]
                @@default_max_allowed_kilobytes = h[:storage_max_allowed_kilobytes]
                @@storage_sub_folders = h[:storage_sub_folders]
            end

            def self.add_sub_folder(name)
                @@storage_sub_folders << name
            end
        end # module Storage
end # module BlackStack
