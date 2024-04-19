# This command checks all the monitors.

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/blackstack-deployer/lib/blackstack-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

l = BlackStack::LocalLogger.new('monitor.log')
conn = [] # array to i

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

while true
  BlackStack::Deployer.nodes.select { |n| !n.parameters[:dev] }.each { |n|
    l.logs "#{n.name.blue}... "

      l.logs "ssh connect... "
      if n.ssh.nil?
        n.connect
        l.logf "connected".green
      else
        l.logf "already connected".yellow
      end

      l.logs "get usage... "
      use = n.usage
      l.logf "done".green

      l.logs 'memory... '
      mem = (use[:mb_free_memory].to_f / use[:mb_total_memory].to_f) * 100.to_f
      l.logf "#{mem.round(2)}%".green

      l.logs 'disk... '
      dsk = (use[:mb_free_disk].to_f / use[:mb_total_disk].to_f) * 100.to_f
      l.logf "#{dsk.round(2)}%".green
      
      l.logs 'cpu... '
      cpu = use[:cpu_load_average].to_i.to_f
      l.logf "#{cpu.round(2)}%".green

    l.logf 'done'.green
  } # each node
end # while true