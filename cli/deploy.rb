# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/my-ruby-deployer/lib/my-ruby-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes

# un-comment this line for testing only.
#require_relative '../../my-ruby-deployer/lib/my-ruby-deployer.rb'

require 'config'
require 'version'

require'deployment/default'
require'deployment/extension'

l = BlackStack::LocalLogger.new('./deploy.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

if BlackStack.sandbox?
  l.log 'Sandbox mode is not allowed by `deploy.rb` command. Remove the `.sandbox` file in the `/cli` directory.'.red
  exit(1)
end

# command parameters 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver.', 
  :configuration => [{
  # installation options
    :name=>'db', 
    :mandatory=>false, 
    :description=>'Enable or disable the deploying of database migrations.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => true,
  }, {
    :name=>'code', 
    :mandatory=>false, 
    :description=>'Install/Updat the source code.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => true,
  }, {
    :name=>'ext', 
    :mandatory=>false, 
    :description=>'Install/Update the source code of the extensions.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => true,
  }, {
    :name=>'restart', 
    :mandatory=>false, 
    :description=>'Stop and start all the processes who run on each node.', 
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
    BlackStack.connection_string # use the connection parameters setting in ./config.rb
  )
  l.done

  l.logs 'Loading checkpoint... '
  BlackStack::Deployer::DB::load_checkpoint("./my-ruby-deployer.lock")
  l.logf "done (#{BlackStack::Deployer::DB::checkpoint.to_s})"

  l.logs 'Running database updates... '
  BlackStack::Deployer::DB::set_folder ('../sql')
  BlackStack::Deployer::DB::deploy(true, "./my-ruby-deployer.lock", l)
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

# run deployment routine to each node 
l.logs 'Install/Update source code... '
if !parser.value('code')
  l.logf 'no'.red
else
  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
    node_name = n.name  

    l.logs "Node #{node_name.blue}... "
    BlackStack::Deployer.run_routine(node_name, routine_name || n.deployment_routine, l)
    l.logf 'done'.green
  } # BlackStack::Deployer.nodes

  l.logf 'done'.green
end # if parser.value('code')

# update the source code of extensions
l.logs 'Install/Update extensions... '
if !parser.value('ext')
  l.logf 'no'.red
else
  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
    node_name = n.name  

    l.logs "Node #{node_name.blue}... "
    BlackStack::Extensions.extensions.each { |e|
      l.logs "Updating code for #{e.name.downcase.to_s.blue}... "
      BlackStack::Deployer.run_routine(node_name, 'extension', l, {
        # name of the git repository
        :extension_name => e.name.downcase, 
        # name of git user beloning the repository of this extension
        :repo_url => e.repo_url, 
        # branch to download from
        :repo_branch => e.repo_branch, 
      })
      l.logf 'done'.green
    }
    l.logf 'done'.green
  } # BlackStack::Deployer.nodes

  l.logf 'done'.green
end # if parser.value('ext')

# update the source code of extensions
l.logs 'Restart processes... '
if !parser.value('restart')
  l.logf 'no'.red
else
  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
    l.logs "Node #{n.name.blue}... "
    n.connect
    n.stop(OUTPUT_FILE)
    n.start(OUTPUT_FILE)
    n.disconnect
    l.logf 'done'.green
  } # BlackStack::Deployer.nodes
  l.logf 'done'.green
end # if parser.value('ext')
