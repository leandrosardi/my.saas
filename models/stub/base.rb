module BlackStack 
    # Base class.
    # List of methods you have to overload if you develop a profile type.
    # 
    class Base
        # object json descriptor
        attr_accessor :desc

        def self.object_name
            raise 'You have to overload this method in your class.'
        end

        def initialize(h)
            self.desc = h
        end

        # Crate an instance of a child class using speicfications in the `desc['name']` attribute.
        # By default, returns the same instance.
        def child_class_instance
            return self
        end

        def self.account_value(field:)
            params = {}
            params['field'] = field
            # call the API
            ret = BlackStack::API.post(
                endpoint: "account_value",
                params: params
            )
            raise "Error calling account_value endpoint: #{ret['status']}" if ret['status'] != 'success'
            return ret['result']
        end # def self.base


        # Get array of hash descriptor of profile.
        # 
        # Parameters: 
        # - page: integer. Page number.
        # - limit: integer. Number of profiles per page.
        # - params: hash. Additional filter parameters used by the specific child class.
        #
        def self.page(page:, limit:, filters: {})
            # add page and limit to the params
            params = {}
            params['page'] = page
            params['limit'] = limit
            params['filters'] = filters
            params['backtrace'] = Mass.backtrace
            # call the API
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/page",
                params: params
            )
            raise "Error calling page endpoint: #{ret['status']}" if ret['status'] != 'success'
            return ret['results'].map { |h| self.new(h).child_class_instance }
        end # def self.base

        # Get array of hash descriptors of profiles.
        # 
        # Parameters: 
        # - id: guid. Id of the profile to bring.
        #
        def self.count
            params = {}
            params['backtrace'] = Mass.backtrace
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/count",
                params: params
            )
            raise "Error calling count endpoint: #{ret['status']}" if ret['status'] != 'success'
            return ret['result'].to_i
        end # def self.count

        # Get array of hash descriptors of profiles.
        # 
        # Parameters: 
        # - id: guid. Id of the profile to bring.
        #
        def self.get(id)
            params = {}
            params['id'] = id
            params['backtrace'] = Mass.backtrace
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/get",
                params: params
            )
            raise "Error calling get endpoint: #{ret['status']}" if ret['status'] != 'success'
            return self.new(ret['result']).child_class_instance
        end # def self.get

        # Submit a hash descriptor to the server for an update
        #
        def self.update(desc)
            params = {}
            params['desc'] = desc
            params['backtrace'] = Mass.backtrace
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/update",
                params: params
            )
            raise "Error calling update endpoint: #{ret['status']}" if ret['status'] != 'success'
            return self.new(ret['result']).child_class_instance
        end # def self.update

        # Submit a hash descriptor to the server for an update
        #
        def update
            self.class.update(self.desc)
        end

        # Submit a hash descriptor to the server for an insert
        #
        def self.insert(desc)
            params = {}
            params['desc'] = desc
            params['backtrace'] = Mass.backtrace
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/insert",
                params: params
            )
            raise "Error calling insert endpoint: #{ret['status']}" if ret['status'] != 'success'
            return self.new(ret['result']).child_class_instance
        end # def self.insert


        # Submit a hash descriptor to the server for an upsert
        #
        def self.upsert(desc)
            params = {}
            params['desc'] = desc
            params['backtrace'] = Mass.backtrace
            ret = BlackStack::API.post(
                endpoint: "#{self.object_name}/upsert",
                params: params
            )
            raise "Error calling upsert endpoint: #{ret['status']}" if ret['status'] != 'success'
            return self.new(ret['result']).child_class_instance
        end # def self.upsert

        # Submit a hash descriptor to the server for an upsert
        #
        def upsert
            self.class.upsert(self.desc)
        end


        # return the HTML of a page downloaded by Zyte.
        #
        # Parameters:
        # - url: the URL of the page to download.
        # - api_key: the Zyte API key.
        # - options: the options to pass to Zyte.
        #
        def zyte_html(url, api_key:, options:, data_filename:)
            ret = nil
            # getting the HTML
            zyte = ZyteClient.new(key: api_key)
            html = zyte.extract(url: url, options: options, data_filename: data_filename) 
            # return the URL of the file in the cloud
            return html
        end # def zyte_html

        # create a file in the cloud with the HTML of a page downloaded by Zyte.
        # return the URL of the file.
        #
        # Parameters:
        # - url: the URL of the page to download.
        # - api_key: the Zyte API key.
        # - options: the options to pass to Zyte.
        # - dropbox_folder: the folder in the cloud where to store the file. If nil, it will use the self.desc['id_account'] value.
        # - min_html_length: the minimum length of the HTML to consider it valid.
        # - retry_times: the number of times to retry the download until the HTML is valid.
        #
        def zyte_snapshot(url, api_key:, options:, data_filename:, dropbox_folder:nil, min_html_length: 10, retry_times: 3)
            ret = nil
            raise "Either dropbox_folder parameter or self.desc['id_account'] are required." if dropbox_folder.nil? && self.desc['id_account'].nil?
            dropbox_folder = self.desc['id_account'] if dropbox_folder.nil?
            # build path to the local file in /tmp
            id = SecureRandom.uuid
            filename = "#{id}.html"
            tmp_path = "/tmp/#{filename}"
            # build path to the file in the cloud
            year = Time.now.year.to_s.rjust(4,'0')
            month = Time.now.month.to_s.rjust(2,'0')
            dropbox_folder = "/massprospecting.bots/#{dropbox_folder}.#{year}.#{month}"
            dropbox_path = "#{dropbox_folder}/#{filename}"
            # getting the HTML - Retry mechanism
            zyte = ZyteClient.new(key: api_key)
            try = 0
            html = nil
            while try < retry_times && html.to_s.length < min_html_length
                html = zyte.extract(url: url, options: options, data_filename: data_filename) 
                try += 1
            end
            # save the HTML in the local file in /tmp
            File.open(tmp_path, 'w') { |file| file.write(html) }
            # create the folder in the cloud and upload the file
            BlackStack::DropBox.dropbox_create_folder(dropbox_folder)
            BlackStack::DropBox.dropbox_upload_file(tmp_path, dropbox_path)
            # delete the local file
            File.delete(tmp_path)
            # return the URL of the file in the cloud
            return BlackStack::DropBox.get_file_url(dropbox_path)
        end # def zyte_snapshot

    end # class Base
end # module Mass