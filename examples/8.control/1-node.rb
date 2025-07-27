# test_node_api.rb
# Example script to test the 4 node access points: create, list, upsert, delete

require 'net/http'
require 'uri'
require 'json'
require 'colorize'
require 'pry'

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

# 1) Create a new node
print "create... "
create_body = {
    ip:             '203.0.113.42',
    provider_type:  'contabo-vps',
    provider_code:  'contabo-xyz-123',
    micro_service:  'worker-rpa',
    slots_quota:    5,
    slots_used:     0
}
resp = post('/node/create.json', create_body)
JSON.pretty_generate(resp)
node_id = resp['id']  # depending on your create handler
ret = resp['status']
puts ret == 'success' ? node_id.blue : ret.to_s.red

# 2) UPSERT the node by IP (will update existing)
print "upsert... "
upsert_body = {
    ip:             '203.0.113.42',
    provider_type:  'contabo-vps',
    provider_code:  'contabo-xyz-123',
    micro_service:  'worker-rpa',
    slots_quota:    15,
    slots_used:     5
}
resp = post('/node/upsert.json', upsert_body)
ret = resp['status']
puts ret == 'success' ? node_id.blue : ret.to_s.red

# 3) GET the list of nodes (page 1, 10 per page)
print "list... "
resp = post('/node/list.json', 'page' => 1, 'per_page' => 10)
ret = resp['status']
puts ret == 'success' ? resp['total'].to_s.blue : ret.to_s.red

# 4) DELETE the node (soft delete)
print 'delete... '
resp = post('/node/delete.json', 'id' => node_id)
ret = resp['status']
puts ret == 'success' ? ret.blue : ret.to_s.red

# 3) GET the list of nodes (page 1, 10 per page)
print "list again... "
resp = post('/node/list.json', 'page' => 1, 'per_page' => 10)
ret = resp['status']
puts ret == 'success' ? resp['total'].to_s.blue : ret.to_s.red

