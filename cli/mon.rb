# This command checks all the monitors.

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/blackstack-deployer/lib/blackstack-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

l = BlackStack::LocalLogger.new('monitor.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

BlackStack::Deployer.nodes.each { |n|
  l.logs "#{n.name.blue}... "
  l.logf 'done'.green
}