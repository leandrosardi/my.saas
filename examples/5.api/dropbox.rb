# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'

res = nil

url = "#{CS_HOME_WEBSITE}/api1.0/dropbox/get_access_token.json"

begin
    params = {
        'api_key' => BlackStack::API.api_key,
        'refresh_token' => 'h6wRt9et40UAAAAAAAAAAWXu0mmyRrB-1GkmVwYKBFKbAD7czd2naa9GtixNBgDj'
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

