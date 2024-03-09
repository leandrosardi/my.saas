# This command is to get the latest n lines of any log in a node.
# Example: 
# ruby tailx.rb name=sinatra1 n=50 filename=/home/ubuntu/code/mysaas/nginx.secure.access.log

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the latest n lines of any log in a node..'
puts 

# command parameters
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command brings the latest n lines of the log of worker.', 
  :configuration => [{
    :name=>'node', 
    :mandatory=>true, 
    :description=>'Name of the node.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'filename', 
    :mandatory=>true, 
    :description=>'Full path and name of the file to show its latest lines.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'n', 
    :mandatory=>false, 
    :description=>'Number of lines to bring.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 10,
  }]
)

# get the node
node = BlackStack::Deployer.nodes.select { |n| n.name == parser.value('node') }.first

# exit if worker not found
if node.nil?
  puts "Node #{parser.value('node')} not found."
  exit(0)
end

# show the tail
puts node.tail(parser.value('filename'), parser.value('n'))
