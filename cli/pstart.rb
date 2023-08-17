# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/blackstack-deployer/lib/blackstack-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

# create logger
l = BlackStack::BaseLogger.new(nil)

# set logger
BlackStack::Pampa.set_logger(l)

l.logs 'Starting Pampa workers... '  
BlackStack::Pampa.start()
l.done
