# This command checks all the monitors.

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/blackstack-deployer/lib/blackstack-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

l = BlackStack::BaseLogger.new(nil)

l.log "Sandbox mode: #{SANDBOX.to_s}"

l.logs 'Connecting to Database... '
DB = BlackStack::CRDB::connect
l.done

BlackStack::Monitoring.monitors.each { |m|
  l.logs "#{m.name}... "
  b = m.pass?
  t = m.get_threshold
  if !t.nil?
    l.logf (b ? "OK".green : "FAIL".red) + " (#{m.last_value} #{m.unit_name} / #{m.get_threshold})"
  else
    l.logf (b ? "OK".green : "FAIL".red) + " (#{m.last_value} #{m.unit_name})"
  end
}