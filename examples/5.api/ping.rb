# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'

res = nil

url = "#{CS_HOME_WEBSITE}/api1.0/ping.json"

begin
    params = {
        'api_key' => BlackStack::API.api_key
    }
    res = BlackStack::Netting::call_post(url, params)
    parsed = JSON.parse(res.body)
    raise parsed['status'] if parsed['status']!='success'
    puts parsed.to_s
rescue Errno::ECONNREFUSED => e
    raise "Errno::ECONNREFUSED:" + e.message
rescue => e2
    raise "Exception:" + e2.message
end

