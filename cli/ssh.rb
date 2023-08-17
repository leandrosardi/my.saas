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
puts 'This command is to get the latest n lines of any log in a node..'
puts 

# command parameters
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command brings the latest n lines of the log of worker.', 
  :configuration => [{
    :name=>'node', 
    :mandatory=>true, 
    :description=>'Name of the node.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
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
    s = "xterm -e 'sudo ssh -i \"#{Shellwords.escape(node.ssh_private_key_file)}\" #{node.ssh_username}@#{node.net_remote_ip} -p #{node.ssh_port}'"
else
    s = "xterm -e 'sudo sshpass -p \"#{Shellwords.escape(node.ssh_password)}\" ssh #{node.ssh_username}@#{node.net_remote_ip} -p #{node.ssh_port}'"
end
#binding.pry
`#{s}`