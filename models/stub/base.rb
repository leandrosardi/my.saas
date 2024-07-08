module Mass 
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
            raise "Error: #{ret['status']}" if ret['status'] != 'success'
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
            raise "Error: #{ret['status']}" if ret['status'] != 'success'
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
            raise "Error: #{ret['status']}" if ret['status'] != 'success'
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
            raise "Error: #{ret['status']}" if ret['status'] != 'success'
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
            raise "Error: #{ret['status']}" if ret['status'] != 'success'
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
            raise "Upserting Error: #{ret['status']}" if ret['status'] != 'success'
            return self.new(ret['result']).child_class_instance
        end # def self.upsert

        # Submit a hash descriptor to the server for an upsert
        #
        def upsert
            self.class.upsert(self.desc)
        end

    end # class Base
end # module Mass