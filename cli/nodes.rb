# This command is to get the status of all nodes: CPU load, memory usage, and disk usage.

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the status of all nodes: CPU load, memory usage, and disk usage.'
puts 

BlackStack::Deployer.nodes.each do |n| 
    puts n.name
    n.usage.each { |k,v| 
        s = "  #{k}: "
        s += ' ' * (30 - s.length)
        print s
        puts v 
    }
    puts
end

