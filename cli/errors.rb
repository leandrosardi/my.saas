# This command is to get the error descriptions of the failed taks of an specific job.
# Example:
# ruby errors.rb name=leads.export.create_file

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'

puts
puts 'This command is to get the error descriptions of the failed taks of an specific job.'
puts 

print 'Connecting the database... '
DB = BlackStack::CRDB::connect
puts 'done'
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

# get the jobs
job = BlackStack::Pampa.jobs.select { |j| j.name == parser.value('worker') }.first

# exit if worker not found
if job.nil?
  puts "Job #{parser.value('worker')} not found."
  exit(0)
end

# get the errors
errors = job.error_descriptions(parser.value('n'))

# show the tail
errors.each { |e| 
  puts e[:id]
  puts e[:description]
  puts 
}

# show total errors
total = (errors.size == parser.value("n")) ? "#{errors.size.to_s}+" : errors.size.to_s
puts "Total errors: #{total.to_s}"
