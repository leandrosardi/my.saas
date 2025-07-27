# test_node_track.rb
# Example script to test the node/track.json access point

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

# Gather real system metrics on Ubuntu 22.04

# 1) TRACK the node by caller IP
print "track... "
# Total RAM in GB (rounded to 2 decimals)
meminfo         = File.read('/proc/meminfo')
total_mem_kb    = meminfo[/MemTotal:\s+(\d+)/,1].to_i
total_ram_gb    = (total_mem_kb / 1024.0 / 1024.0).round(2)

# Total disk size on root (in GB)
total_disk_gb   = `df -BG --output=size / | tail -1 | tr -dc '0-9'`.to_i

# Current RAM usage as percentage
available_kb    = meminfo[/MemAvailable:\s+(\d+)/,1].to_i
used_mem_kb     = total_mem_kb - available_kb
current_ram_usage = (used_mem_kb * 100.0 / total_mem_kb).round(2)

# Current disk usage as percentage
current_disk_usage = `df -h --output=pcent / | tail -1 | tr -dc '0-9'`.to_i

# Current CPU usage as percentage (1‑second snapshot)
current_cpu_usage = `top -bn1 | grep "Cpu(s)" | \
  awk '{print 100 - $8}'`.to_f.round(2)

track_body = {
  # NOTE: ip is taken from request.ip, so we do NOT include it here
  provider_type:  'contabo-vps',
  provider_code:  'contabo-xyz-123',
  micro_service:  'worker-rpa',
  slots_quota:    10,
  slots_used:     2,
  total_ram_gb:   total_ram_gb,
  total_disk_gb:  total_disk_gb,
  current_ram_usage:   current_ram_usage,
  current_disk_usage:  current_disk_usage,
  current_cpu_usage:   current_cpu_usage,
  max_ram_usage:       75.0,
  max_disk_usage:      85.0,
  max_cpu_usage:       90.0,
  # lifecycle timestamps & flags
=begin
  creation_time:              Time.now.iso8601,
  creation_success:           true,
  creation_error_description: nil,
  installation_time:          Time.now.iso8601,
  installation_success:       true,
  installation_error_description: nil,
  migrations_time:            Time.now.iso8601,
  migrations_success:         true,
  migrations_error_description: nil,
  last_start_time:            Time.now.iso8601,
  last_start_success:         true,
  last_start_description:     nil,
  last_stop_time:             nil,
  last_stop_success:          nil,
  last_stop_description:      nil
=end
}

resp = post('/node/track.json', track_body)
if resp['status'] == 'success'
  puts "tracked node #{resp['node_id']}".blue
else
  puts resp['status'].red
end
