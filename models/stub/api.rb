module BlackStack 
    module API
        @@api_key = nil
        @@api_url = nil
        @@api_version = '1.0'
        @@api_port = nil
        @@classes = {}

        def self.api_key
            @@api_key
        end # def self.api_key

        def self.api_url
            @@api_url
        end # def self.api_url

        def self.api_version
            @@api_version
        end # def self.api_version

        def self.api_port
            @@api_port
        end # def self.api_port

        def self.classes
            @@classes
        end # def self.classes

        def self.set_client(
            api_key: ,
            api_url: ,
            api_version: '1.0',
            api_port: nil
        )
            @@api_key = api_key
            @@api_url = api_url
            @@api_version = api_version
            @@api_port = api_port
        end # def self.set_client

        def self.set_server(
            classes: {}
        )
            @@classes = classes
        end # def self.set_server

        def self.post(
            endpoint: , 
            params: {}
        )
            begin
                url = "#{@@api_url}:#{@@api_port}/api#{@@api_version}/#{endpoint}.json"
                params['api_key'] = @@api_key
                res = BlackStack::Netting.call_post(url, params)
                parsed = JSON.parse(res.body)
                return JSON.parse(res.body)

                ## write response.body into a file
                # File.open('response.body.html', 'w') { |file| file.write(res.body) }
            rescue => e
                return {
                    'status' => e.message,
                    'value' => e.to_console
                }
            end
        end # def self.post

    end # module API
end # module Mass