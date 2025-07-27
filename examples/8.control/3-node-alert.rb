# test_node_alert.rb
# Example script to test upserting into the node_alert table via /node_alert/create.json

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

# Replace this with an existing node ID in your system
node_id = '99d2eb66-1471-43ec-a358-ab6a05508c79'

# 1) Create a new alert (insert)
print "create alert... "
upsert_body = {
  id_node:        node_id,
  type:           'CPU_THRESHOLD',
  description:    'CPU usage exceeded threshold',
  screenshot_url: 'http://example.com/snap1.png',
  solved:         false 
}
resp2 = post('/node_alert/upsert.json', upsert_body)
alert_id2 = resp2['id']
status2   = resp2['status']
puts(status2 == 'success' ? alert_id2.blue : status2.red)