# encoding: utf-8
#
# conn.rb : Test the database connection configuration.
# Author: Leandro D. Sardi (https://github.com/leandrosardi).
#
# Use this command to see the raw connection string to the database, and test it.
# 
require 'mysaas'
require 'lib/stubs'
require 'config'

puts
puts 'This command is to test the connection to a database..'

# command parameters
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command brings the latest n lines of the log of worker.', 
  :configuration => [{
    :name=>'node', 
    :mandatory=>true, 
    :description=>'Name of the node.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)

# get the node descriptor from the Deployer module
node = BlackStack::Deployer.nodes.select { |n| n.name == parser.value('node') }.first

# exit if worker not found
if node.nil?
  puts "Node #{parser.value('node')} not found.".red
  exit(0)
end

# exit if the node has not a parameter[:db_type]
if node.parameters[:db_type].nil?
  puts "Node #{parser.value('node')} has no database configuration.".red
  exit(0)
end

# exit if the node has not a value :pg or :crdb into parameter[:db_type]
if node.parameters[:db_type] != :pg && node.parameters[:db_type] != :crdb
  puts "Node #{parser.value('node')} has no database configuration.".red
  exit(0)
end

# if the node has a db_type, then show the connection string
puts "Node #{node.name} has a database configuration.".green

if node.parameters[:db_type] == :pg
  puts "Database type: PostgreSQL".green
end

if node.parameters[:db_type] == :crdb
  puts "Database type: CockroachDB".green
end

if node.parameters[:db_type] == :pg
  BlackStack::PostgreSQL::set_db_params({ 
    :db_url => node.net_remote_ip, 
    :db_port => node.parameters[:db_port],
    :db_name => node.parameters[:db_name],
    :db_user => node.parameters[:db_user],
    :db_password => node.parameters[:db_password],
  })
end

if node.parameters[:db_type] == :crdb
  BlackStack::CockroachDB::set_db_params({
    :db_url => node.net_remote_ip,
    :db_cluster => node.parameters[:db_cluster],
    :db_sslmode => node.parameters[:db_sslmode],
    :db_port => node.parameters[:db_port],
    :db_name => node.parameters[:db_name],
    :db_user => node.parameters[:db_user],
    :db_password => node.parameters[:db_password],
  })
end

# test the connection
l = BlackStack::BaseLogger.new(nil)
BlackStack.db_test(l)
exit(0)