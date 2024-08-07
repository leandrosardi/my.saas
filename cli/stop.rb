# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/my-ruby-deployer/lib/my-ruby-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes

# un-comment this line for testing only.
#require_relative '../../my-ruby-deployer/lib/my-ruby-deployer.rb'

require 'config'
require 'version'

l = BlackStack::LocalLogger.new('./stop.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

if BlackStack.sandbox?
  l.log 'Sandbox mode is not allowed by `stop.rb` command. Remove the `.sandbox` file in the `/cli` directory.'.red
  exit(1)
end

# command parameters 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will stop all processes assigned to run on each node.', 
  :configuration => [{
  # web server installation
    :name=>'nodes', 
    :mandatory=>false, 
    :description=>'Regular expresion to filter the nodes by name.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }]
)

# if the user specified a list of nodes, bring only the nodes that match the regular expression, even if they are development nodes.
# if the user did not specified a list of nodes, bring all production nodes only.

if parser.value('nodes') == '.*'
  l.log 'No nodes specified. Using the default value: .*'
  nodes = BlackStack::Deployer.nodes.select { |n| n.parameters[:dev].to_s != 'true' }
else
  nodes = BlackStack::Deployer.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }
end

# each node has its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
nodes.each { |n|
  l.logs "Node #{n.name.blue}... "
  n.connect
  n.stop(OUTPUT_FILE)
  n.disconnect
  l.logf 'done'.green
} # BlackStack::Deployer.nodes
