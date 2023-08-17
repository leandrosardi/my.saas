# This command is to get the status of all jobs: idle, running, failed.

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the status of all nodes: CPU load, memory usage, and disk usage.'
puts 

print 'Connecting the database... '
DB = BlackStack::CRDB::connect
puts 'done'

BlackStack::Pampa.jobs.each do |j| 
    puts "#{j.name}:"
    
    s = "  idle: "
    s += ' ' * (30 - s.length)
    print s
    puts j.idle

    s = "  running: "
    s += ' ' * (30 - s.length)
    print s
    puts j.running

    s = "  failed: "
    s += ' ' * (30 - s.length)
    print s
    puts j.failed

    puts
end 

