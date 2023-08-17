require 'controllers/extensions/leftbaricon'
require 'controllers/extensions/dependency'
require 'controllers/extensions/settingscreen'
require 'controllers/extensions/storagefolder'
require 'controllers/extensions/extension'

module BlackStack
    module BackUp
        # mysaas end-user "refresh-token" to grab a new "access-code" every time is needed.
        @@dropbox_refresh_token = nil
        # list of folders and files to backup
        @@destinations = []

        # getters 
        def self.dropbox_refresh_token
            @@dropbox_refresh_token
        end

        # getters 
        def self.destinations
            @@destinations
        end

        # Setup the bakcup module.
        def self.set(h)
            @@dropbox_refresh_token = h[:dropbox_refresh_token]
            @@destinations = h[:destinations]
        end # set

        # Get an access code using the refresh token.
        #
        def self.dropbox_get_access_token
            # get the refresh token
            ret = `curl --silent --location --request POST 'https://api.dropboxapi.com/oauth2/token' -u '#{DROPBOX_APP_KEY}:#{DROPBOX_APP_SECRET}' -d 'grant_type=refresh_token' -d 'refresh_token=#{@@dropbox_refresh_token}'`
            h = JSON.parse(ret)
            if h.include? 'error'
                raise h['error_description']
            else
                return h['access_token']
            end
        end

        # Upload a file to dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # use `2>&1 1>/dev/null` to suppress verbose output of shell command.
        # reference: https://stackoverflow.com/questions/18525359/suppress-verbose-output-of-shell-command-in-python
        def self.dropbox_upload_file(localfilename, cloudfilename)
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/upload \\
            --header \"Authorization: Bearer #{BlackStack::BackUp.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\": \\\"#{cloudfilename}\\\", \\\"mode\\\": \\\"overwrite\\\"}\" \\
            --header \"Content-Type: application/octet-stream\" \\
            --data-binary @#{localfilename}"
            ret = `#{s}`
            h = JSON.parse(ret)
            raise h['error_summary'] if h.include? 'error_summary'
        end

        # Create a folder into dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # use `2>&1 1>/dev/null` to suppress verbose output of shell command.
        # reference: https://stackoverflow.com/questions/18525359/suppress-verbose-output-of-shell-command-in-python
        def self.dropbox_create_folder(cloudfoldername, verbose=false)
            s = "curl --silent -X POST https://api.dropboxapi.com/2/files/create_folder_v2 \\
            --header \"Authorization: Bearer #{BlackStack::BackUp.dropbox_get_access_token}\" \\
            --header \"Content-Type: application/json\" \\
            --data \"{\\\"autorename\\\":false,\\\"path\\\":\\\"#{cloudfoldername}\\\"}\""
            return `#{s}` if verbose
            return `#{s} 2>&1 1>/dev/null` unless verbose
        end

        # Upload a files and folders to dropbox
        #
        # This method is for internal use only.
        # End-users should use the BlackStack::Backup::backup method.
        # 
        # Iterate over directories and subdirectories recursively showing 'path/file'.
        # reference: https://stackoverflow.com/questions/40016856/iterate-over-directories-and-subdirectories-recursively-showing-path-file-in-r
        #
        # pfolder: name of the cloud folder
        # psource: pattern to list the files and folders to upload
        # log: logger object
        #
        def self.upload(pfolder, psource, verbose=false, log=nil)
            #log.logs "uploading "
            #log.logf "#{psource} --> #{pfolder}"
            
            # get the path from the ls command
            #log.logs "getting path... "
            local_folder = psource.gsub(/\/#{Regexp.escape(psource.split('/').last)}$/, '')
            #log.logf local_folder

            Dir.glob(psource).each do |file|
                # decide if it is a file or a folder
                type = File.directory?(file) ? 'folder' : 'file'
                # remove the source from the path
                file.gsub!(/^#{Regexp.escape(local_folder)}\//, '')
                log.logs "#{type}, #{file}... "
                ret = ''
                if type == 'file'
                    ret = BlackStack::BackUp::dropbox_upload_file("#{local_folder}/\"#{file}\"", "/#{pfolder}/\"#{file}\"")
                else
                    ret = BlackStack::BackUp::dropbox_create_folder("/#{pfolder}/\"#{file}\"", verbose)
                    BlackStack::BackUp::upload("#{pfolder}/#{file}", "#{local_folder}/\"#{file}\"/*", verbose, log)
                end
                verbose ? log.logf(ret) : log.done
            end
        end

        # Run the backup process.
        def self.backup(verbose=false, log=nil)
            log = BlackStack::DummyLogger.new(nil) if log.nil?
            timestamp = Time.now.getutc.to_s.gsub(/[^0-9a-zA-Z\.]/, '')
            @@destinations.each { |d|
                # parameters
                foldername = d[:folder] # how to name this backup in dropbox 
                source = d[:source] # source folder to backup

                # build a unique folder name using the current timestamp.
                log.logs "#{foldername}... "
                    folder = "#{timestamp}.#{foldername}"
                    
                    log.logs "Create folder #{folder}... "
                    BlackStack::BackUp::dropbox_create_folder(folder, verbose)
                    log.done
                    
                    log.logs "Upload files... "
                    BlackStack::BackUp::upload(folder, source, verbose, log)
                    log.done
                log.done
            }
        end

        # Run the restore process
        #
        # NOTE: Download a folder from the user's Dropbox, as a zip file. 
        # The folder must be less than 20 GB in size and any single file within must be less than 4 GB in size. 
        # The resulting zip must have fewer than 10,000 total file and folder entries, including the top level folder. 
        # The input cannot be a single file. Note: this endpoint does not support HTTP range requests.
        # 
        # Reference: https://www.dropbox.com/developers/documentation/http/documentation#files-download_zip
        # 
        # Parameters: 
        # - cloudfoldername: name of the folder in dropbox to download. The zip file will be saved in the folder where the command is running.
        # - zipfilename: name of the zip file to save.
        # - unzip: activate thisf lag if you want to unzip the downloaded zip file.
        # - destination: path of the local folder where you want to unzip.
        # - deletezipfile: activate this if you want to delete the zip file after unzipping.
        #
        # Activate the unzip if you have installed the zip command.
        # Reference: https://iq.direct/blog/49-how-to-unzip-file-on-ubuntu-linux.html 
        #
        def self.restore(cloudfoldername, log=nil, zipfilename='temp.zip', unzip=false, destination=nil, deletezipfile=false)
            log.logs 'Downloading backup folder... '
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/download_zip \\
            --header \"Authorization: Bearer #{BlackStack::BackUp.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\":\\\"/#{cloudfoldername}/\\\"}\" --output #{zipfilename} 2>&1 1>/dev/null"
            `#{s}`

            log.done

            if unzip
                log.logs 'Unzipping backup folder... '
                s = "
                rmdir ./tempy 2>/dev/null;
                mkdir ./tempy;
                unzip #{zipfilename} -d ./tempy;
                mv ./tempy/#{cloudfoldername}/* #{destination};
                rm -rf ./tempy 2>/dev/null;
                "
                `#{s}`
                log.done
                if deletezipfile
                    log.logs 'Deleting zip file... '
                    `rm #{zipfilename}`
                    log.done
                end
            end
        end # def self.restore

        def self.dropbox_download_file(cloudfoldername, cloudfilename, destination=nil)
            s = "curl --silent -X POST https://content.dropboxapi.com/2/files/download \\
            --header \"Authorization: Bearer #{BlackStack::BackUp.dropbox_get_access_token}\" \\
            --header \"Dropbox-API-Arg: {\\\"path\\\":\\\"/#{cloudfoldername}/#{cloudfilename}\\\"}\" --output #{destination}/#{cloudfilename} 2>&1 1>/dev/null"
            `#{s}`
        end # def self.dropbox_download_file

        # Reference: https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder
        def self.dropbox_folder_files(cloudfoldername)
            s = "curl --silent -X POST https://api.dropboxapi.com/2/files/list_folder \\
            --header \"Authorization: Bearer #{BlackStack::BackUp.dropbox_get_access_token}\" \\
            --header \"Content-Type: application/json\" \\
            --data \"{\\\"include_deleted\\\":false,\\\"include_has_explicit_shared_members\\\":false,\\\"include_media_info\\\":false,\\\"include_mounted_folders\\\":true,\\\"include_non_downloadable_files\\\":true,\\\"path\\\":\\\"/#{cloudfoldername}/\\\"}\""
            output = `#{s}`
            ret = JSON.parse(output)
            ret['entries'].map { |e| e['name'] }
        end # def self.dropbox_folder_files
    end # module Extensions
end # module BlackStack
