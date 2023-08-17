# This command is to get the status of all workers: running or idle?

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the status of all workers: running or idle?.'
puts 

BlackStack::Pampa.nodes.each do |n| 
    puts n.name
    n.workers.each { |w| 
        s = "  #{w.id}: "
        s += ' ' * (30 - s.length)
        print s
        i = BlackStack::Pampa.log_minutes_ago(n.name, w.id)
        puts i.to_s
    }
    puts
end
