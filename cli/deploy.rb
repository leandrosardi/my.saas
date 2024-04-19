# encoding: utf-8

print 'Loading libraries... '
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
require 'deployment/default'
require 'deployment/extension'
puts 'done'.green

l = BlackStack::LocalLogger.new('./deploy.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

if BlackStack.sandbox?
  #l.log 'Sandbox mode is not allowed by `deploy.rb` command. Remove the `.sandbox` file in the `/cli` directory.'.red
  #exit(1)
  l.log 'Warning: Sandbox mode is not recommended to run `deploy.rb` command. Remove the `.sandbox` file in the `/cli` directory.'.yellow
end

# command parameters 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will apply migrations into database, pull source code from repositry, install/update extensions, and restart processes assigned to run on each node.', 
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

  # TODO: make a better way to decide which nodes are master nodes
  l.logs 'Loading master nodes (nodes that serve as database servers)... ' 
  masters = BlackStack::Deployer.nodes.select { |n| 
    n.name=~/#{parser.value('nodes')}/ && 
    !n.parameters[:db_type].nil? && 
    n.parameters[:dev].to_s != 'true' 
  }
  l.logf 'done'.green + " (#{masters.size.to_s.blue} nodes)"

  masters.each { |node|
    l.logs "Node #{node.name.blue}... "

    if node.parameters[:db_type] != :pg && node.parameters[:db_type] != :crdb
      l.logf 'skipped'.yellow + " (only :pg and :crdb are supported)"
    end

    if node.parameters[:db_type] == :pg
      BlackStack::PostgreSQL::set_db_params({ 
        :db_url => node.net_remote_ip, 
        :db_port => node.parameters[:db_port],
        :db_name => node.parameters[:db_name],
        :db_user => node.parameters[:db_user],
        :db_password => node.parameters[:db_password],
      })
    end

    if node.parameters[:db_type] == :crdb
      BlackStack::CockroachDB::set_db_params({
        :db_url => node.net_remote_ip,
        :db_cluster => node.parameters[:db_cluster],
        :db_sslmode => node.parameters[:db_sslmode],
        :db_port => node.parameters[:db_port],
        :db_name => node.parameters[:db_name],
        :db_user => node.parameters[:db_user],
        :db_password => node.parameters[:db_password],
      })
    end

    l.logs 'Connecting the database... '
    BlackStack::Deployer::DB.connect(
      BlackStack.connection_string # use the connection parameters setting in ./config.rb
    )
    l.logf 'done'.green

    l.logs 'Loading checkpoint... '
    BlackStack::Deployer::DB::load_checkpoint("./my-ruby-deployer.lock")
    l.logf "done".green + " (#{BlackStack::Deployer::DB::checkpoint.to_s})"

    l.logs 'Running database updates... '
    BlackStack::Deployer::DB::set_folder ('../sql')
    BlackStack::Deployer::DB::deploy(true, "./my-ruby-deployer.lock", l)
    l.logf 'done'.green

    # run the .sql scripts of each extension
    BlackStack::Extensions.extensions.each { |e|
      l.logs "Loading checkpoint for #{e.name.downcase.blue}... "
      BlackStack::Deployer::DB::load_checkpoint("./my-ruby-deployer.#{e.name.downcase}.lock")
      l.logf "done".green + " (#{BlackStack::Deployer::DB::checkpoint.to_s})"

      l.logs "Running database updates for #{e.name.downcase.blue}... "
      BlackStack::Deployer::DB::set_folder ("../extensions/#{e.name.downcase}/sql")
      BlackStack::Deployer::DB::deploy(true, "./my-ruby-deployer.#{e.name.downcase}.lock")
      l.logf 'done'.green
    }

    # disconnecting from the database
    l.logs 'Disconnecting the database... '
    #BlackStack::Deployer::DB.disconnect
    #l.logf 'done'.green
    l.logf "TODO: develop disconnect method!"

    l.logf 'done'.green

  } # masters.each
end # if parser.value('db')

# run deployment routine to each node 
l.logs 'Install/Update source code... '
if !parser.value('code')
  l.logf 'no'.red
else
  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| 
    n.name=~/#{parser.value('nodes')}/ && 
    n.parameters[:dev].to_s != 'true' 
  }.each { |n|
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
  BlackStack::Deployer.nodes.select { |n| 
    n.name=~/#{parser.value('nodes')}/ &&
    n.parameters[:dev].to_s != 'true'
  }.each { |n|
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
  BlackStack::Deployer.nodes.select { |n| 
    n.name=~/#{parser.value('nodes')}/ &&
    n.parameters[:dev].to_s != 'true'
  }.each { |n|
    l.logs "Node #{n.name.blue}... "
    n.connect
    n.stop(OUTPUT_FILE)
    n.start(OUTPUT_FILE)
    n.disconnect
    l.logf 'done'.green
  } # BlackStack::Deployer.nodes
  l.logf 'done'.green
end # if parser.value('ext')
