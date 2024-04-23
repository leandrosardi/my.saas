# Open a new terminal using xterm and open a ssh connection to the node.
# Example:
# ruby ssh.rb name=n01
#

# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
require 'config.rb'
require 'shellwords'

puts
puts 'This command is to connect a node via SSH using the connection parameters in the configuration file.'
puts 

# command parameters
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command brings the latest n lines of the log of worker.', 
  :configuration => [{
    :name=>'node', 
    :mandatory=>true, 
    :description=>'Name of the node.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }, {
    :name=>'show', 
    :mandatory=>false, 
    :description=>'Show the SSH command executed.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default=>false
  }]
)

# get the node
node = BlackStack::Deployer.nodes.select { |n| n.name == parser.value('node') }.first

# exit if worker not found
if node.nil?
  puts "Node #{parser.value('node')} not found."
  exit(0)
end

# TODO: move this to the node class
# if the node has a key, use it
s = nil
if node.ssh_private_key_file
    s = "ssh -o StrictHostKeyChecking=no -i \"#{Shellwords.escape(node.ssh_private_key_file)}\" #{node.ssh_username}@#{node.net_remote_ip} -p #{node.ssh_port}"
else
    s = "sshpass -p \"#{Shellwords.escape(node.ssh_password)}\" ssh -o StrictHostKeyChecking=no #{node.ssh_username}@#{node.net_remote_ip} -p #{node.ssh_port}"
end

puts "Command: #{s.blue}" if parser.value('show')

system(s)
