# This command is to get the latest log lines of a worker.
# Example:
# ruby tailw.rb id=node1.1 n=50

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the latest log lines of a worker.'
puts 

# command parameters
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command brings the latest n lines of the log of worker.', 
  :configuration => [{
    :name=>'worker', 
    :mandatory=>true, 
    :description=>'Full ID of the worker, including the node name (example: <nodename>.1).', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'n', 
    :mandatory=>false, 
    :description=>'Number of lines to bring.', 
    :type=>BlackStack::SimpleCommandLineParser::INT,
    :default => 10,
  }]
)

# contatenates all the nodes' workeers into a single array.
workers = []
BlackStack::Pampa.nodes.each { |n| workers += n.workers }

# get the worker
worker = workers.select { |w| w.id == parser.value('worker') }.first

# exit if worker not found
if worker.nil?
  puts "Worker #{parser.value('id')} not found."
  exit(0)
end

# show the tail
puts worker.tail(parser.value('n'))
