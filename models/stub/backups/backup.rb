require 'controllers/extensions/leftbaricon'
require 'controllers/extensions/dependency'
require 'controllers/extensions/settingscreen'
require 'controllers/extensions/storagefolder'
require 'controllers/extensions/extension'

module BlackStack
    module BackUp
        # list of folders and files to backup
        @@destinations = []

        # getters 
        def self.destinations
            @@destinations
        end

        # Setup the bakcup module.
        def self.set(h)
            @@destinations = h[:bucket]
        end # set

        # Run the backup process.
        # - Iterate destinations one by one.
        # - Create a folder and a backup-folder in dropbox.
        # - Upload files to dropbox.
        def self.backup(l=nil)
            l = BlackStack::DummyLogger.new(nil) if l.nil?
            timestamp = Time.now.getutc.to_s.gsub(/[^0-9a-zA-Z\.]/, '')
            @@destinations.each { |d|
                # build a unique folder name using the current timestamp.
                l.logs "#{d[:name].blue}... "
                    name = d[:name]
                    path = d[:path]
                    folder = d[:folder]
                    backup_folder = "#{folder}/#{timestamp}"

                    l.logs "Create folder #{backup_folder.blue}... "
                    BlackStack::DropBox.dropbox_create_folder("/#{backup_folder}")
                    l.logf 'done'.green

                    l.logs "Create folder #{folder.blue}... "
                    BlackStack::DropBox.dropbox_create_folder("/#{folder}")
                    l.logf 'done'.green
                    
                    d[:files].each { |file|
                        l.logs "Upload #{file.blue} to #{folder.blue}... "
                        BlackStack::DropBox.dropbox_upload_file("#{path}/#{file}", "/#{folder}/#{name}/#{file}")
                        l.logf 'done'.green
                    }

                    d[:files].each { |file|
                        l.logs "Upload #{file.blue} to #{backup_folder.blue}... "
                        BlackStack::DropBox.dropbox_upload_file("#{path}/#{file}", "/#{backup_folder}/#{name}/#{file}")
                        l.logf 'done'.green
                    }

                l.logf 'done'.green
            }
        end

        # Run the restore process
        def self.restore(timestamp=nil, l=nil)
            l = BlackStack::DummyLogger.new(nil) if l.nil?
            @@destinations.each { |d|
                # build a unique folder name using the current timestamp.
                l.logs "#{d[:name].blue}... "
                    name = d[:name]
                    path = d[:path]
                    folder = timestamp ? "#{folder}/#{timestamp}" : d[:folder]
                    
                    d[:files].each { |file|
                        l.logs "Download #{file.blue} from #{folder.blue}... "
                        BlackStack::DropBox.dropbox_download_file("#{folder}/#{name}", file, path)
                        l.logf 'done'.green
                    }
                l.logf 'done'.green
            }
        end # def self.restore

    end # module Extensions
end # module BlackStack
