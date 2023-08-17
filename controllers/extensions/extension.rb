module BlackStack
    module Extensions
        # This module is to define a an extnsion
        module ExtensionModule
            # return an array of strings with the errors found on the hash descriptor
            def self.validate_descriptor(h)
                errors = []

                # validate: h must be a hash
                errors << "extension descriptor must be a hash" unless h.is_a?(Hash)

                # only if h is a hash
                if h.is_a?(Hash)
                    # validate: the key :name is required
                    errors << ":name is required" if h[:name].to_s.size==0

                    # validate: the key :name is required
                    #errors << ":large_name is required" if h[:large_name].to_s.size==0

                    # validate: the value of h[:name] must be a string
                    errors << ":name must be a string" if !h[:name].is_a?(String)

                    # validate: the key :description is required
                    errors << ":description is required" if h[:description].to_s.size==0

                    # validate: the value of h[:description] must be a string
                    errors << ":description must be a string" if !h[:description].is_a?(String)

                    # validate: the key :repo_url is required
                    errors << ":repo_url is required" if h[:repo_url].to_s.size==0

                    # validate: the value of h[:repo_url] must be a string
                    errors << ":repo_url must be a string" if !h[:repo_url].is_a?(String)

                    # validate: the key :repo_branch is required
                    errors << ":repo_branch is required" if h[:repo_branch].to_s.size==0

                    # validate: the value of h[:repo_branch] must be a string
                    errors << ":repo_branch must be a string" if !h[:repo_branch].is_a?(String)

                    # validate: the key :author is required
                    errors << ":author is required" if h[:author].to_s.size==0

                    # validate: the value of h[:author] must be a string
                    errors << ":author must be a string" if !h[:author].is_a?(String)

                    # validate: the key :version is required
                    errors << ":version is required" if h[:version].to_s.size==0

                    # validate: the value of h[:version] must be a string
                    errors << ":version must be a string" if !h[:version].is_a?(String)

                    # if the key :services_section exists, it must be a string
                    if h[:services_section].to_s.size>0
                        errors << ":services_section must be a string" if !h[:services_section].is_a?(String)
                    end

                    # if the key :show_in_top_bar exists, it must be a bool
                    if h[:show_in_top_bar].to_s.size>0
                        errors << ":show_in_top_bar must be a bool" if !h[:show_in_top_bar].is_a?(TrueClass) and !h[:show_in_top_bar].is_a?(FalseClass)
                    end

                    # if the key :show_in_footer exists, it must be a bool
                    if h[:show_in_footer].to_s.size>0
                        errors << ":show_in_footer must be a bool" if !h[:show_in_footer].is_a?(TrueClass) and !h[:show_in_footer].is_a?(FalseClass)
                    end

                    # if the key :show_in_dashboard exists, it must be a bool
                    if h[:show_in_dashboard].to_s.size>0
                        errors << ":show_in_dashboard must be a bool" if !h[:show_in_dashboard].is_a?(TrueClass) and !h[:show_in_dashboard].is_a?(FalseClass)
                    end

                    # if exists the key :dependencies
                    if h[:dependencies].to_s.size>0
                        # validate: the value of h[:dependencies] must be an array
                        errors << ":dependencies must be an array" if !h[:dependencies].is_a?(Array)

                        # validate: each element of h[:dependencies] must be a valid dependency descriptor
                        h[:dependencies].each do |i|
                            e = BlackStack::Extensions::DependencyModule::validate_descriptor(i)
                            errors << ":dependencies must be an array of dependency descriptors. Errors found: #{e.join(". ")}" if e.size>0
                        end
                    end # if exists the key :dependencies

                    # if the key :leftbar_icons exists, it must be an array, and each array element must be a valid leftbaricon descriptor
                    if h[:leftbar_icons].to_s.size>0
                        errors << ":leftbar_icons must be an array" if !h[:leftbar_icons].is_a?(Array)
                        h[:leftbar_icons].each do |i|
                            e = BlackStack::Extensions::LeftBarIconModule::validate_descriptor(i)
                            errors << ":leftbar_icons must be an array of leftbaricon descriptors. Errors found: #{e.join(". ")}" if e.size>0
                        end
                    end

                    # if the key :setting_screens exists, it must be an array, and each array element must be a valid settingscreen descriptor
                    if h[:setting_screens].to_s.size>0
                        errors << ":setting_screens must be an array" if !h[:setting_screens].is_a?(Array)
                        h[:setting_screens].each do |i|
                            e = BlackStack::Extensions::SettingScreenModule::validate_descriptor(i)
                            errors << ":setting_screens must be an array of settingscreen descriptors. Errors found: #{e.join(". ")}" if e.size>0
                        end
                    end

                    # if the key :storage_folders exists, it must be an array, and each array element must be a valid storagefolder descriptor
                    if h[:storage_folders].to_s.size>0
                        errors << ":storage_folders must be an array" if !h[:storage_folders].is_a?(Array)
                        h[:storage_folders].each do |i|
                            e = BlackStack::Extensions::StorageFolderModule::validate_descriptor(i)
                            errors << ":storage_folders must be an array of storagefolder descriptors. Errors found: #{e.join(". ")}" if e.size>0
                        end
                    end

                    # if the key :deployment_routines exists, it must be an array, and each array element must be a valid routine descriptor
                    if h[:deployment_routines].to_s.size>0
                        errors << ":deployment_routines must be an array" if !h[:deployment_routines].is_a?(Array)
                        h[:deployment_routines].each do |i|
                            e = BlackStack::Deployer::RoutineModule::descriptor_errors(i)
                            errors << ":deployment_routines must be an array of :deployment_routines descriptors. Errors found: #{e.join(". ")}" if e.size>0
                        end
                    end

                    # if the key :css_files exists, it must be an array of strings
                    errors << ":css_files must be an array" if h[:css_files].to_s.size>0 and !h[:css_files].is_a?(Array)

                    # if the key :js_files exists, it must be an array of strings
                    errors << ":js_files must be an array" if h[:js_files].to_s.size>0 and !h[:js_files].is_a?(Array)
                end

                # return
                errors
            end

            def update(h)
                # map the hash descriptor to the attributes of the object
                self.name = h[:name] if h[:name].to_s.size>0
                self.large_name = h[:large_name] if h[:name].to_s.size>0
                self.description = h[:description] if h[:description].to_s.size>0
                self.repo_url = h[:repo_url] if h[:repo_url].to_s.size>0
                self.repo_branch = h[:repo_branch] if h[:repo_branch].to_s.size>0
                self.author = h[:author] if h[:author].to_s.size>0
                self.version = h[:version] if h[:version].to_s.size>0

                self.services_section = h[:services_section] if h[:services_section].to_s.size>0
                self.show_in_top_bar = h[:show_in_top_bar] if h[:show_in_top_bar].to_s.size>0
                self.show_in_footer = h[:show_in_footer] if h[:show_in_footer].to_s.size>0
                self.show_in_dashboard = h[:show_in_dashboard] if h[:show_in_dashboard].to_s.size>0

                if h[:dependencies].to_s.size>0
                    self.dependencies.clear # i have to clean the array, in the user wants to update it
                    h[:dependencies].each do |i|
                        self.dependencies << BlackStack::Extensions::Dependency.new(i) 
                    end
                end

                if h[:leftbar_icons].to_s.size>0
                    self.leftbar_icons.clear # i have to clean the array, in the user wants to update it
                    h[:leftbar_icons].each do |i|
                        self.leftbar_icons << BlackStack::Extensions::LeftBarIcon.new(i)
                    end
                end

                if h[:setting_screens].to_s.size>0
                    self.setting_screens.clear # i have to clean the array, in the user wants to update it
                    h[:setting_screens].each do |i|
                        self.setting_screens << BlackStack::Extensions::SettingScreen.new(i)
                    end
                end

                if h[:storage_folders].to_s.size>0
                    self.storage_folders.clear # i have to clean the array, in the user wants to update it
                    h[:storage_folders].each do |i|
                        self.storage_folders << BlackStack::Extensions::StorageFolder.new(i)
                    end
                end

                if h[:deployment_routines].to_s.size>0
                    self.deployment_routines.clear # i have to clean the array, in the user wants to update it
                    h[:deployment_routines].each do |i|
                        self.deployment_routines << BlackStack::Deployer::Routine.new(i)
                    end
                end

                if h[:css_files].to_s.size>0
                    self.css_files.clear # i have to clean the array, in the user wants to update it
                    h[:css_files].each do |i|
                        self.css_files << i
                    end
                end

                if h[:js_files].to_s.size>0
                    self.js_files.clear # i have to clean the array, in the user wants to update it
                    h[:js_files].each do |i|
                        self.js_files << i
                    end
                end
            end # def update

            # map a hash descriptor to the attributes of the object
            def initialize(h)
                # find errors in the descriptor
                errors = BlackStack::Extensions::ExtensionModule::validate_descriptor(h)        
                # if there are errors, raise an exception
                raise "Errors found: #{errors.join(". ")}" if errors.size>0
                # update parameters
                self.update(h)
            end # set

            # get a hash descriptor of the object
            def to_hash
                h = {}
                
                h[:name] = self.name if self.name.to_s.size>0
                h[:large_name] = self.large_name if self.large_name.to_s.size>0
                h[:description] = self.description if self.description.to_s.size>0
                h[:repo_url] = self.repo_url if self.repo_url.to_s.size>0
                h[:repo_branch] = self.repo_branch if self.repo_branch.to_s.size>0
                h[:author] = self.author if self.author.to_s.size>0
                h[:version] = self.version if self.version.to_s.size>0
                    
                h[:services_section] = self.services_section if self.services_section.to_s.size>0
                h[:show_in_top_bar] = self.show_in_top_bar if self.show_in_top_bar.to_s.size>0
                h[:show_in_footer] = self.show_in_footer if self.show_in_footer.to_s.size>0
                h[:show_in_dashboard] = self.show_in_dashboard if self.show_in_dashboard.to_s.size>0

                if self.dependencies.size>0
                    h[:dependencies] = []
                    self.dependencies.each do |i|
                        h[:dependencies] << i.to_hash
                    end
                end

                if self.leftbar_icons.size>0
                    h[:leftbar_icons] = []
                    self.leftbar_icons.each do |i|
                        h[:leftbar_icons] << i.to_hash
                    end
                end

                if self.setting_screens.size>0
                    h[:setting_screens] = []
                    self.setting_screens.each do |i|
                        h[:setting_screens] << i.to_hash
                    end
                end

                if self.storage_folders.size>0
                    h[:storage_folders] = []
                    self.storage_folders.each do |i|
                        h[:storage_folders] << i.to_hash
                    end
                end

                if self.deployment_routines.size>0
                    h[:deployment_routines] = []
                    self.deployment_routines.each do |i|
                        h[:deployment_routines] << i.to_hash
                    end
                end

                if self.css_files.size>0
                    h[:css_files] = []
                    self.css_files.each do |i|
                        h[:css_files] << i
                    end
                end

                h
            end # to_hash
        end # module ExtensionModule
    end # module Extensions
end # module BlackStack