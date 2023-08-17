# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# loading a user, who is not deleted
u = BlackStack::MySaaS::User.where(:delete_time => nil).first
# => nil

# output
puts "User Name: #{u.name}"
# => User Name: leandro.sardi

puts "User ID: #{u.id}"
# => User ID: 34f3980a-6efc-4d02-8043-d226860f26fe

puts "User Email: #{u.email}"
# => User Email: a@a.com

# setting up a new preference
name = 'default-marketplace-section' # name of the preference
default = 'cellphones' # set this when `value.nil?`
value = 'bikes'
puts u.preference(name, default, value)
# => bikes

# getting a preference
puts u.preferences.select { |p| p.name=='default-marketplace-section' }.first.get_value
# => bikes
