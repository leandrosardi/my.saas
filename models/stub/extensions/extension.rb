require 'my-ruby-deployer'

module BlackStack
    module Extensions
        # This module is to define a an extnsion
        class Extension
            include BlackStack::Extensions::ExtensionModule
            attr_accessor :name, :large_name, :version, :description, :author, :repo_url, :repo_branch
            attr_accessor :services_section, :show_in_top_bar, :show_in_footer, :show_in_dashboard
            attr_accessor :dependencies, :leftbar_icons, :setting_screens, :storage_folders
            attr_accessor :deployment_routines
            attr_accessor :css_files # array of strings
            attr_accessor :js_files # array of strings

            def initialize(h)
                self.dependencies = []
                self.leftbar_icons = []
                self.setting_screens = []
                self.storage_folders = []
                self.deployment_routines = []
                self.css_files = []
                self.js_files = []
                super(h)
            end
        end # class Extension   
    end # module Extensions
end # module BlackStack