# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/my-ruby-deployer/lib/my-ruby-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

require'deployment/install-webserver'

l = BlackStack::LocalLogger.new('./deploy.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

# command parameters 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver.', 
  :configuration => [{
  # installation options
    :name=>'db', 
    :mandatory=>false, 
    :description=>'Enable or disable the deploying of database migrations.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }, {
    :name=>'code', 
    :mandatory=>false, 
    :description=>'Enable or disable the deploying of source code.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => true,
  }, {
  # web server installation
    :name=>'nodes', 
    :mandatory=>false, 
    :description=>'Regular expresion to filter the nodes by name.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }, {
  # web server installation
    :name=>'routine', 
    :mandatory=>false, 
    :description=>'Name of the routine to execute. Default: take default routine of each node.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '-',
=begin
  }, {
  # web server installation
    :name=>'show_output', 
    :mandatory=>false, 
    :description=>'Activate this flag if you want to see the show_output of each bash command executed.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
=end
  }]
)

# grab the name of the routine
routine_name = parser.value('routine') == '-' ? nil : parser.value('routine')

# run database updates
l.logs 'Deploy database migrations?... '
if !parser.value('db')
  l.logf 'no'.red 
else
  l.logf 'yes'.green 

  l.logs 'Connecting the database... '
  BlackStack::Deployer::DB::connect(
    BlackStack::CRDB::connection_string # use the connection parameters setting in ./config.rb
  )
  l.done

  l.logs 'Loading checkpoint... '
  BlackStack::Deployer::DB::load_checkpoint("./my-ruby-deployer.lock")
  l.logf "done (#{BlackStack::Deployer::DB::checkpoint.to_s})"

  l.logs 'Running database updates... '
  BlackStack::Deployer::DB::set_folder ('../sql')
  BlackStack::Deployer::DB::deploy(true, "./my-ruby-deployer.lock")
  l.done

  # run the .sql scripts of each extension
  BlackStack::Extensions.extensions.each { |e|
    l.logs "Loading checkpoint for #{e.name.downcase}... "
    BlackStack::Deployer::DB::load_checkpoint("./my-ruby-deployer.#{e.name.downcase}.lock")
    l.logf "done (#{BlackStack::Deployer::DB::checkpoint.to_s})"

    l.logs "Running database updates for #{e.name.downcase}... "
    BlackStack::Deployer::DB::set_folder ("../extensions/#{e.name.downcase}/sql")
    BlackStack::Deployer::DB::deploy(true, "./my-ruby-deployer.#{e.name.downcase}.lock")
    l.done
  }
end # if parser.value('db')

# restart webserver
# Reference: https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon
l.logs 'Deploy code updates... '
if !parser.value('code')
  l.logf 'no'.red
else
  l.logf 'yes'.green

  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
    node_name = n.name  

    l.logs "Node #{node_name.blue}... "
    BlackStack::Deployer.run_routine(node_name, routine_name || n.deployment_routine, l)
    l.logf 'done'.green
  } # BlackStack::Deployer.nodes
end # if parser.value('web')