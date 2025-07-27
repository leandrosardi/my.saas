# test_general_int_parameter.rb
# Example script to test upserting into the general_int_parameter table via /general_int_parameter/upsert.json

require 'net/http'
require 'uri'
require 'json'
require 'colorize'

BASE_URL = 'http://127.0.0.1:3000/api2.0'
API_KEY  = '98c60163-3412-4952-85da-a7fa823f459f'  # replace with your super‑user API key

def post(endpoint, body)
  uri = URI("#{BASE_URL}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  req  = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.body = body.merge(api_key: API_KEY).to_json
  resp = http.request(req)
  JSON.parse(resp.body)
end

print "upsert parameter... "
create_body = {
  name:        'max_connections',
  description: 'Maximum allowed DB connections',
  value:       100,
  min:         10,
  max:         500,
  solved:      false
}
resp1   = post('/general_int_parameter/upsert.json', create_body)
param_id = resp1['id']
status1  = resp1['status']
puts(status1 == 'success' ? param_id.blue : status1.red)

