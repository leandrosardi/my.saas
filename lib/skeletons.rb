require 'lib/stubs'
require 'models/skeleton/core/account'
require 'models/skeleton/core/user'
require 'models/skeleton/core/login'
require 'models/skeleton/core/timezone'
require 'models/skeleton/core/preference'

require 'models/skeleton/core/daily'
require 'models/skeleton/core/hourly'
require 'models/skeleton/core/minutely'

require 'models/skeleton/core/notification'
require 'models/skeleton/core/notificationopen'
require 'models/skeleton/core/notificationlink'
require 'models/skeleton/core/notificationclick'

require 'models/skeleton/core/country'
require 'models/skeleton/core/state'



module BlackStack
    module InsertUpdate
        # return a Sequel dataset, based on some filters.
        # this method is used by the API to get the data from the database remotely
        def base_list(account=nil, filters: {})
            ds = nil
            if account
                ds = self.where(:id_account => account.id, :delete_time => nil)
            else
                ds = self.where(:delete_time => nil)
            end
            return ds
        end

        # return a Sequel dataset, based on some filters and some pagination parameters.
        # this method is used by the API to get the data from the database remotely
        def page(account=nil, page:, limit:, filters: {})
            ds = self.list(account, filters: filters)
            ds = ds.limit(limit).offset((page-1)*limit).order(:create_time)
            return ds
        end

        # insert a record
        # 
        # parameters:
        # - upsert_children: call upsert on children objects, or call insert on children objects
        # 
        # return the object
        def insert(h={}, upsert_children: true)
            h = self.normalize(h)
            errors = self.errors(h)
            raise errors.join("\n") if errors.size > 0

            b = upsert_children
            o = self.new
            o.id = h['id'] || guid
            o.id_account = h['id_account']
            o.id_user = h['id_user']
            o.create_time = now
            o.update(h, upsert_children: b)
            o.save
            return o
        end

        # insert or update a record
        # 
        # parameters:
        # - upsert_children: call upsert on children objects, or call insert on children objects
        # 
        # return the object
        def upsert(h={}, upsert_children: true)
            o = self.find(h)
            b = upsert_children
            if o.nil?
                o = self.insert(h, upsert_children: b)
            else
                o.update(h, upsert_children: b)
            end

            return o
        end # def self.upsert

        # insert or update an array of hash descriptors
        def insert_update_many(a, logger: nil)
            l = logger || BlackStack::DummyLogger.new
            i = 0
            a.each do |h|
                i += 1
                l.logs "Processing record #{i}/#{a.size}... " 
                self.upsert(h)
                l.logf 'done'.green
            end
        end # def insert_update_many
    end

    module Serialize
        # update a record
        # 
        # parameters:
        # - upsert_children: call upsert on children objects, or call insert on children objects.
        # - manage_done_time: if this is moving fom the status :pending to another status at first time, set the done_time.
        # 
        # return the object
        def base_update(h={}, upsert_children: true, manage_done_time: false)
            h = self.class.normalize(h)
            errors = self.class.errors(h)
            raise errors.join("\n") if errors.size > 0
            
            # if this is moving fom the status :pending to another status at first time, set the done_time
            if manage_done_time
                if self.status == self.class.status_code(:pending) && !h['status'].to_s.empty? && h['status'].to_sym != :pending && self.done_time.nil? 
                    self.done_time = now
                end
            end
            
            return self
        end

        # call the method upsert for each element of the array a.
        def to_h_base
            {
                'id' => self.id,
                'id_account' => self.id_account,
                'id_user' => self.id_user,
                'create_time' => self.create_time,
                'update_time' => self.update_time,
                'delete_time' => self.delete_time,
            }
        end # def to_h

        def save
            self.update_time = now
            super
        end
    end

    module Palette
        # parameter rgb is an array of 3 integers, each one between 0 and 255.
        # return an integer with the RGB value.
        def rgb_to_int(rgb)
            ret = 0
            ret += rgb[0] << 16
            ret += rgb[1] << 8
            ret += rgb[2]
            return ret
        end # def rgb_to_int

        # parameter rgb is an array of 3 integers, each one between 0 and 255.
        # return the HEX for the RGB value.
        def rgb_to_hex(rgb)
            ret = "#"
            rgb.each do |c|
                ret += c.to_s(16).rjust(2, '0')
            end
            return ret
        end # def rgb_to_hex

        # parameter n is an integer between 0 and 16777215.
        # return an array of 3 integers, each one between 0 and 255.
        def int_to_rgb(n)
            ret = []
            ret[0] = (n >> 16) & 0xFF
            ret[1] = (n >> 8) & 0xFF
            ret[2] = n & 0xFF
            return ret
        end # def int_to_rgb

        # parameter n is an integer between 0 and 16777215.
        # return the HEX for the RGB value.
        def int_to_hex(n)
            rgb = self.int_to_rgb(n)
            return self.rgb_to_hex(rgb)
        end

        # Return a hash with 25 RGB values
        # Each color must support black text inside. 
        # So, avoid dark colors.
        def pallette
            {
                :red => [255, 0, 0],
                :green => [0, 255, 0],
                :blue => [0, 0, 255],
                :yellow => [255, 255, 0],
                :orange => [255, 165, 0],
                :cyan => [0, 255, 255],
                :magenta => [255, 0, 255],
                :white => [255, 255, 255],
                :gray => [128, 128, 128],
                :maroon => [128, 0, 0],
                :olive => [128, 128, 0],
                :navy => [0, 0, 128],
                :purple => [128, 0, 128],
                :teal => [0, 128, 128],
                :light_blue => [173, 216, 230],
                :light_green => [144, 238, 144],
                :light_red => [255, 182, 193],
                :black => [0, 0, 0],            
            }
        end # def pallette

        # parameter key is a symbol
        # return the HEX for the RGB value defined in the palette.
        def pallette_to_hex(key)
            rgb = self.pallette[key]
            return self.rgb_to_hex(rgb)
        end # def pallette_to_hex

        # parameter key is a symbol
        # return the RGB value defined in the palette.
        def pallette_to_rgb(key)
            return self.pallette[key]
        end # def pallette_to_rgb

        # parameter key is a symbol
        # return the RGB value defined in the palette.
        def pallette_to_int(key)
            rgb = self.pallette[key]
            return self.rgb_to_int(rgb)
        end # def pallette_to_int
    end # module Palette


    module Storage
        # Download a file form the web and store it in Dropbox.
        # Return the URL of the file in Dropbox.
        #
        # Parameters:
        # - url: the URL of the file to download.
        # - filename: the name of the file to store in Dropbox.
        # - dropbox_folder: the name of the folder in Dropbox where the file will be stored. E.g.: "channels/#{account.id}".
        # - downloadeable: if true, the returnled URL will allow the download of the file. If false, the URL will show the file in the browser.
        # 
        def store(url:, filename:, dropbox_folder:, downloadeable: false)
            tempfile = nil
            if url =~ /^http(s)?\:\/\//
                tempfile = Down.download(url)
            elsif url =~ /^file\:\/\//
                tempfile = File.open(url.gsub(/^file\:\/\//, '/'))
            end
            year = Time.now.year.to_s.rjust(4,'0')
            month = Time.now.month.to_s.rjust(2,'0')
            folder = "/massprospecting.bots/#{dropbox_folder}.#{year}.#{month}"
            path = "#{folder}/#{filename}"
            BlackStack::DropBox.dropbox_create_folder(folder)
            BlackStack::DropBox.dropbox_upload_file(tempfile.path, path)
            ret = BlackStack::DropBox.get_file_url(path)
            ret.gsub!(/\&dl\=1/, "&dl=0") if downloadeable == false
            # delete the temporary file if I downloaded it form the web
            if url =~ /^http(s)?\:\/\//
                # delete the temporary file from the hard drive
                File.delete(tempfile.path) if File.exists?(tempfile.path)
            end
            # return the URL of the file in Dropbox.
            return ret
        end
    end # module Storage

    module Status
        # return an array with the different type of states
        # - :pending - it is waiting to be executed
        # - :running - it is being executed right now
        # - :performed - it was executed successfully
        # - :failed - it was executed with errors
        # - :aborted - it started but it was aborted because filters didn't pass
        # - :canceled - it was canceled by the user
        # 
        def statuses
            [:pending, :running, :performed, :failed, :aborted, :canceled]
        end # def self.accesses
        
        # return an array with the color of differy type of status
        def status_colors
            [:gray, :blue, :green, :red, :black, :black]
        end # def self.state_colors

        # return position of the array self.states, with the key.to_sym value
        def status_code(key)
            self.statuses.index(key.to_sym)
        end # def self.access
    end # module Status

    module DomainProtocol
        # return an array with the different type of domain_protocols
        # 
        def domain_protocols
            [:http, :https]
        end # def self.domain_protocols
        
        # return position of the array self.domain_protocols, with the key.to_sym value
        def domain_protocols_code(key)
            self.domain_protocols.index(key.to_sym)
        end # def self.domain_protocols_code
    end # module DomainProtocol

    module Validation
        INDEED_COMPANY_PATTERN = /^https\:\/\/(www\.)?indeed\.com\/cmp\//
        APOLLO_COMPANY_PATTERN = /^https\:\/\/app\.apollo\.io\/\#\/organizations\//

        # normalize the values of the descriptor.
        def normalize(h={})
            h['id_account'] = h['id_account'].to_s.strip.downcase if h['id_account']
            h['id_user'] = h['id_user'].to_s.strip.downcase if h['id_user']
            return h
        end # def self.normalize

        # return an array of error messages if there are keys now allowed
        def key_errors(h={}, allowed_keys:)
            allowed_keys += [:id_account, :id_user, :id, :create_time, :update_time, :delete_time] 
            ret = []
            h.keys.each do |k|
                ret << "The key '#{k}' is not allowed in #{self.name.gsub('Mass::', '')}." if !allowed_keys.map { |s| s.to_s }.include?(k.to_s)
            end
            return ret
        end # def key_errors

        # validate some keys of the hash descriptor are present
        def mandatory_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} is required for #{self.name.gsub('Mass::', '')}." if h[k.to_s].nil? || h[k.to_s].to_s.empty?
            end
            return ret
        end # def mandatory_errors

        # validate the values of some specific keys are valid URLs.
        def url_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                unless h[k.to_s].nil? || h[k.to_s].to_s.empty?
                    # validate the URL is reachable
                    if h[k.to_s].to_s.valid_url?
                        begin
                            uri = URI.parse(h[k.to_s])
                            response = Net::HTTP.get_response(uri)
                            ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} is not reachable." if response.code.to_i != 200
                        rescue
                            ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} is not reachable."
                        end
                    elsif h[k.to_s].to_s.valid_filename?
                        ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} is not reachable." if !File.exists?(h[k.to_s].gsub(/^file\:\/\//, '/'))
                    else
                        ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} is not a valid URL or File."
                    end
                end
            end # keys.each
            return ret
        end # def url_errors

        # validate the values of some specific keys are valid Emails.
        def email_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid Email." if h[k.to_s] && !h[k.to_s].to_s.match(/^[\w\.\-]+@[\w\.\-]+\.\w+$/)
            end # keys.each
            return ret
        end # def email_errors

        def normalize_linkedin_url(url)
            # remove query string parameters
            url = url.gsub(/\?.*$/, '')
            # remove # at the end
            url = url.gsub(/\#.*$/, '')
            # add 'http' at the begining if it doesn't exists
            url = "http://#{url}" if !url.match(/^http(s)?\:\//)
            # add 'www.' at the begining if it doesn't exists
            url = url.gsub(/^http(s)?\:\/\/(www\.)?/, 'https://www.')
            # remove the last '/' if it exists
            url = url.gsub(/\/$/, '')
            return url.to_s.downcase
        end

        # validate the values of some specific keys are valid Emails.
        def linkedin_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                url = h[k.to_s].nil? ? nil : self.normalize_linkedin_url(h[k.to_s])
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid LinkedIn URL." if url && !url.to_s.match(/^http(s)?\:\/\/(www\.)?linkedin\.com\/in\/[^\/]+$/i)
            end # keys.each
            return ret
        end # def linkedin_errors


        def normalize_linkedin_company_url(url)
            # remove query string parameters
            url = url.gsub(/\?.*$/, '')
            # remove # at the end
            url = url.gsub(/\#.*$/, '')
            # add 'http' at the begining if it doesn't exists
            url = "http://#{url}" if !url.match(/^http(s)?\:\//)
            # add 'www.' at the begining if it doesn't exists
            url = url.gsub(/^http(s)?\:\/\/(www\.)?/, 'https://www.')
            # remove the last '/' if it exists
            url = url.gsub(/\/$/, '')
            return url.to_s.downcase
        end

        # validate the values of some specific keys are valid Emails.
        def linkedin_company_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                url = h[k.to_s].nil? ? nil : self.normalize_linkedin_company_url(h[k.to_s])
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid LinkedIn URL." if url && !url.to_s.match(/^http(s)?\:\/\/(www\.)?linkedin\.com\/company\/[^\/]+$/i)
            end # keys.each
            return ret
        end # def linkedin_errors


        def normalize_indeed_company_url(url)
            url.split('?').first
        end

        def normalize_apollo_company_url(url)
            url.split('?').first
        end

        # validate the values of some specific keys are valid Indeed company URL.
        def indeed_company_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                url = h[k.to_s].nil? ? nil : self.normalize_indeed_company_url(h[k.to_s])
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid Indeed URL." if url && url.to_s !~ INDEED_COMPANY_PATTERN
            end # keys.each
            return ret
        end # def linkedin_errors

        # validate the values of some specific keys are valid Apollo company URL.
        def apollo_company_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                url = h[k.to_s].nil? ? nil : self.normalize_apollo_company_url(h[k.to_s])
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid Apollo URL." if url && url.to_s !~ APOLLO_COMPANY_PATTERN
            end # keys.each
            return ret
        end # def linkedin_errors

        # validate the values of some specific keys are valid tristates.
        def tristate_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid tristate (#{BlackStack::Tristate.tristates.join(",")})." if h[k.to_s] && BlackStack::Tristate.tristates.index(h[k.to_s].to_sym).nil?
            end # keys.each
            return ret
        end # def linkedin_errors

        def normalize_facebook_url(url)
            # remove query string parameters
            url = url.gsub(/\?.*$/, '')
            # remove # at the end
            url = url.gsub(/\#.*$/, '')
            # add 'http' at the begining if it doesn't exists
            url = "http://#{url}" if !url.match(/^http(s)?\:\//)
            # remove 'www.'
            url = url.gsub(/^http(s)?\:\/\/(www\.)?/, 'https://')
            # add 'www.' at the begining if it doesn't exist
            url = url.gsub(/^http(s)?\:\/\/(web\.)?/, 'https://web.')
            # remove /refname/
            url = url.gsub(/\/refname\//, '/')
            # remove the last '/' if it exists
            url = url.gsub(/\/$/, '')
            return url.to_s.downcase
        end

        # validate the values of some specific keys are valid Emails.
        def facebook_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                url = h[k.to_s].nil? ? nil : self.normalize_facebook_url(h[k.to_s])
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid Facebook URL." if url && !url.to_s.match(/^http(s)?\:\/\/(web\.)?facebook\.com\/[a-z0-9\-\._]+$/i)
            end # keys.each
            return ret
        end # def linkedin_errors


        def normalize_facebook_company_url(url)
            normalize_facebook_url(url)
        end

        # validate the values of some specific keys are valid Emails.
        def facebook_company_errors(h={}, keys:)
            facebook_errors(h, keys: keys)
        end # def linkedin_errors

        # get domain from url using URI
        def normalize_email(email)
            email.to_s.strip.downcase
        end

        # get domain from url using URI
        def normalize_domain(url)
            url = url.to_s.strip.downcase
            # remove query string parameters
            url = url.gsub(/\?.*$/, '')
            # remove # at the end
            url = url.gsub(/\#.*$/, '')
            # add 'http' at the begining if it doesn't exists
            url = "http://#{url}" if !url.match(/^http(s)?\:\//)
            # remove 'www.'
            url = url.gsub(/^http(s)?\:\/\/(www\.)?/, '')
            # add 'www.' at the begining if it doesn't exist
            url = url.gsub(/^http(s)?\:\/\/(web\.)?/, '')
            # remove the last '/' if it exists
            url = url.gsub(/\/$/, '')
            # remove protoco
            url = url.gsub(/^http\:\/\//, '')
            url = url.gsub(/^https\:\/\//, '')
            return url.to_s.downcase
        end

        # validate the values of some specific keys are valid strings
        def string_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a string." if h[k.to_s] && !h[k.to_s].is_a?(String)
            end
            return ret
        end # def string_errors

        # validate the values of some specific keys are valid domains
        def domain_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a valid domain." if h[k.to_s] && !h[k.to_s].to_s.strip.downcase.valid_domain?
            end
            return ret
        end # def domain_errors

        # validate the values of some specific keys are valid integers, between 2 values.
        def int_errors(h={}, min:, max:, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be an integer." if h[k.to_s] && !h[k.to_s].is_a?(Integer)
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be greater than #{min}." if h[k.to_s] && h[k.to_s].is_a?(Integer) && h[k.to_s] < min
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be less than #{max}." if h[k.to_s] && h[k.to_s].is_a?(Integer) && h[k.to_s] > max
            end
            return ret
        end # def int_errors

        # validate the values of some specific keys are valid floats, between 2 values.
        def float_errors(h={}, min:, max:, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a float." if h[k.to_s] && !h[k.to_s].is_a?(Float)
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be greater than #{min}." if h[k.to_s] && h[k.to_s].is_a?(Float) && h[k.to_s] < min
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be less than #{max}." if h[k.to_s] && h[k.to_s].is_a?(Float) && h[k.to_s] > max
            end
            return ret
        end # def float_errors

        # validate the values of some specific keys are valid booleans.
        def boolean_errors(h={}, keys:)
            ret = []
            keys.each do |k|
                ret << "The #{k} '#{h[k.to_s].to_s}' for #{self.name.gsub('Mass::', '')} must be a boolean." if h[k.to_s] && ![true, false].include?(h[k.to_s])
            end
            return ret
        end # def boolean_errors
        

        # return an array of error messages regarding the ownership of the object.
        def ownership_errors(h={})
            ret = []

            ret << "The id_account for #{self.name.gsub('Mass::', '')} is required." if h['id_account'].nil? || h['id_account'].to_s.empty?
            ret << "The id_account for #{self.name.gsub('Mass::', '')} must be a guid." if h['id_account'] && !h['id_account'].to_s.guid?
            ret << "The id_account for #{self.name.gsub('Mass::', '')} must exist." if h['id_account'] && h['id_account'].to_s.guid? && BlackStack::MySaaS::Account.where(:id => h['id_account']).first.nil?

            ret << "The id_user for #{self.name.gsub('Mass::', '')} must be a guid." if h['id_user'] && !h['id_user'].to_s.guid?
            ret << "The id_user for #{self.name.gsub('Mass::', '')} must exist." if h['id_user'] && h['id_user'].to_s.guid? && BlackStack::MySaaS::User.where(:id => h['id_user']).first.nil?

            if h['id_account'] && h['id_user']
                # user must be belonging the account
                ret << "The user for #{self.name.gsub('Mass::', '')} must belong to the account." if BlackStack::MySaaS::User.where(:id => h['id_user'], :id_account => h['id_account']).first.nil?
            end

            return ret
        end # def ownership_errors

        # return an array of error messages regarding the naming of the object.
        # validations:
        # - name is required.
        # - the name must be unique.
        # - the name must be a string.
        # - the name must be less than 255 characters.
        # 
        def naming_errors(h={})
            h = self.normalize(h)
            ret = []
            ret << "The name for #{self.name.gsub('Mass::', '')} is required." if h['name'].nil? || h['name'].to_s.empty?
            ret << "The name for #{self.name.gsub('Mass::', '')} must be a string." if h['name'] && !h['name'].is_a?(String)
            ret << "The name for #{self.name.gsub('Mass::', '')} must be less than 255 characters." if h['name'] && h['name'].is_a?(String) && h['name'].to_s.length > 255
=begin
            # name must be unique
            ret << "Name is unique and already exists a #{self.name.gsub('Mass::', '')} with the same name." if h['name'] && h['id'].nil? && self.where(
                :id_account => h['id_account'], 
                :name => h['name'].to_s
            ).first
            ret << "Name is unique and already exists a #{self.name.gsub('Mass::', '')} with the same name." if h['name'] && h['id'] && self.where(Sequel.lit("
                id_account = '#{h['id_account']}' AND
                name = '#{h['name'].to_s.to_sql}' AND
                id != '#{h['id']}'
            ")).first
=end
            return ret
        end # def naming_errors

        # return an array of error messages regarding the color of the object.
        def color_errors(h={})
            ret = []
            ret << "The color_code for #{self.name.gsub('Mass::', '')} must be a symbol or string." if h['color_code'] && !h['color_code'].is_a?(Symbol) && !h['color_code'].is_a?(String)
            ret << "The color_code for #{self.name.gsub('Mass::', '')} must be a valid key from the palette." if h['color_code'] && h['color_code'].is_a?(Symbol) && !pallette.keys.include?(h['color_code'].to_sym)
            return ret
        end # def color_errors

    end # module Validation

    module Tristate
        def self.tristates
            [:any, :yes, :no]
        end

        def tristates
            BlackStack::Tristate.tristates
        end

        def tristate_code(key)
            self.tristates.index(key.to_sym)
        end
    end

end 