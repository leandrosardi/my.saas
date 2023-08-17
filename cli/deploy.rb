# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/blackstack-deployer/lib/blackstack-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'
require'deployment-routines/all-routines'

l = BlackStack::BaseLogger.new(nil)

l.log "Sandbox mode: #{SANDBOX.to_s}"

# command parameters 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a Sinatra-based BlackStack webserver.', 
  :configuration => [{
  # installation options
    :name=>'db', 
    :mandatory=>false, 
    :description=>'Enable or disable the installation and running of the cockroachdb server, with the creation of the schema and seed of the tables.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }, {
    :name=>'web', 
    :mandatory=>false, 
    :description=>'Enable or disable the installation and running of the web server.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }, {
    :name=>'pampa', 
    :mandatory=>false, 
    :description=>'Enable or disable the deployment of pampa nodes.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }, {
    :name=>'workmesh', 
    :mandatory=>false, 
    :description=>'Enable or disable the deployment of workmesh nodes.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }, {
  # web server installation
    :name=>'nodes', 
    :mandatory=>false, 
    :description=>'Regular expresion to filter the nodes by name.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => '.*',
  }, {
  # web server installation
    :name=>'show_output', 
    :mandatory=>false, 
    :description=>'Activate this flag if you want to see the show_output of each bash command executed.', 
    :type=>BlackStack::SimpleCommandLineParser::BOOL,
    :default => false,
  }]
)

# set logger
BlackStack::Deployer.set_logger(l)
BlackStack::Pampa.set_logger(l)

# enable/disable output
BlackStack::Deployer.set_show_output(parser.value('show_output'))

# run database updates
if parser.value('db')
  l.logs 'Connecting the database... '
  BlackStack::Deployer::DB::connect(
    BlackStack::CRDB::connection_string # use the connection parameters setting in ./config.rb
  )
  l.done

  l.logs 'Loading checkpoint... '
  BlackStack::Deployer::DB::load_checkpoint
  l.logf "done (#{BlackStack::Deployer::DB::checkpoint.to_s})"

  l.logs 'Running database updates... '
  BlackStack::Deployer::DB::set_folder ('../sql')
  BlackStack::Deployer::DB::deploy(true)
  l.done

  # run the .sql scripts of each extension
  BlackStack::Extensions.extensions.each { |e|
    l.logs "Loading checkpoint for #{e.name.downcase}... "
    BlackStack::Deployer::DB::load_checkpoint("./blackstack-deployer.#{e.name.downcase}.lock")
    l.logf "done (#{BlackStack::Deployer::DB::checkpoint.to_s})"

    l.logs "Running database updates for #{e.name.downcase}... "
    BlackStack::Deployer::DB::set_folder ("../extensions/#{e.name.downcase}/sql")
    BlackStack::Deployer::DB::deploy(true, "./blackstack-deployer.#{e.name.downcase}.lock")
    l.done
  }
end # if parser.value('db')

# restart webserver
# Reference: https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon
if parser.value('web')

  # TODO: each node should have its routine, so deployer should run the assigned routine to each node, no matter of it is web or pampa.
  BlackStack::Deployer.nodes.select { |n| n.name =~ /^s.*/ }.select { |n| n.name=~/#{parser.value('nodes')}/ }.map { |n| n.name }.each { |node_name|
  l.logs "Deploying webserver on #{node_name}... "

    l.logs 'Upload config.rb... '
    BlackStack::Deployer::run_routine(node_name, 'setup-mysaas-upload-config')
    l.done

    l.logs 'Update source code & gems... '
      l.logs 'MySaas... '
        BlackStack::Deployer::run_routine(node_name, 'install-mysaas')
      l.done

      BlackStack::Extensions.extensions.each { |e|
        l.logs "Update extension #{e.name.downcase}... "
          BlackStack::Deployer::add_routine({
            :name => "install-#{e.name.downcase}",
            :commands => [{ 
                  :command => "
                    cd $HOME/code/mysaas/extensions;
                    git clone #{e.repo_url};
                  ",
                  :matches => [ 
                      /already exists and is not an empty directory/i,
                      /Cloning into/i,
                      /Resolving deltas\: 100\% \((\d)+\/(\d)+\), done\./i,
                      /fatal\: destination path \'.+\' already exists and is not an empty directory\./i,
                  ],
                  :nomatches => [ # no output means success.
                      { :nomatch => /error/i, :error_description => 'An Error Occurred' },
                  ],
                  :sudo => false,
              }, { 
                  :command => "
                    cd $HOME/code/mysaas/extensions/#{e.name.downcase};
                    git fetch --all;
                  ",
                  :matches => [/\-> origin\//, /^Fetching origin$/],
                  :nomatches => [ { :nomatch => /error/i, :error_description => 'An error ocurred.' } ],
                  :sudo => false,
              }, { 
                  :command => "
                    cd $HOME/code/mysaas/extensions/#{e.name.downcase};
                    git reset --hard origin/#{e.repo_branch};
                  ",
                  :matches => /HEAD is now at/,
                  :sudo => false,      
              }
            ],
          });

          BlackStack::Deployer::run_routine(node_name, "install-#{e.name.downcase}")
        
        l.done
      }
    l.done

    l.logs 'Stopping web server... '
    BlackStack::Deployer::run_routine(node_name, 'stop-mysaas')
    l.done  

    l.logs 'Starting web server... '
    BlackStack::Deployer::run_routine(node_name, 'start-mysaas')
    l.done

    l.logs 'Running extensions routines... '
      BlackStack::Extensions.extensions.each { |e|
        l.logs "#{e.name.downcase}... "

          e.deployment_routines.each { |r|
            l.logs "Running #{r.name}... "
            BlackStack::Deployer::add_routine(r.to_hash)
            BlackStack::Deployer::run_routine(node_name, r.name)
            l.done
          }

        l.done
      }
    l.done

  l.done # l.logs "Deploying webserver on #{node_name}... "
  } # BlackStack::Deployer.nodes
end # if parser.value('web')

# deploy pampa workers
if parser.value('pampa')
  l.logs 'Installing Pampa Nodes... '
    BlackStack::Pampa.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
      l.logs "Installing Pampa node #{n.name}... "
        l.logs 'Upload config.rb... '
          BlackStack::Deployer::run_routine(n.name, 'setup-mysaas-upload-config')
        l.done

        l.logs 'Installing MySaas... '
          BlackStack::Deployer::run_routine(n.name, 'install-mysaas')
        l.done

        BlackStack::Extensions.extensions.each { |e|
          l.logs "Installing extension #{e.name.downcase}... "
          BlackStack::Deployer::add_routine({
            :name => "install-#{e.name.downcase}",
            :commands => [{ 
                  :command => "
                    cd $HOME/code/mysaas/extensions;
                    git clone #{e.repo_url};
                  ",
                  :matches => [ 
                      /already exists and is not an empty directory/i,
                      /Cloning into/i,
                      /Resolving deltas\: 100\% \((\d)+\/(\d)+\), done\./i,
                      /fatal\: destination path \'.+\' already exists and is not an empty directory\./i,
                  ],
                  :nomatches => [ # no output means success.
                      { :nomatch => /error/i, :error_description => 'An Error Occurred' },
                  ],
                  :sudo => false,
              }, { 
                  :command => "
                    cd $HOME/code/mysaas/extensions/#{e.name.downcase};
                    git fetch --all;
                  ",
                  :matches => [/\-> origin\//, /^Fetching origin$/],
                  :nomatches => [ { :nomatch => /error/i, :error_description => 'An error ocurred.' } ],
                  :sudo => false,
              }, { 
                  :command => "
                    cd $HOME/code/mysaas/extensions/#{e.name.downcase};
                    git reset --hard origin/#{e.repo_branch};
                  ",
                  :matches => /HEAD is now at/,
                  :sudo => false,      
              }
            ],
          });

          BlackStack::Deployer::run_routine(n.name, "install-#{e.name.downcase}")
          l.done
        }
        
        l.logs 'Running extensions routines... '
          BlackStack::Extensions.extensions.each { |e|
            l.logs "Running routines for extension #{e.name.downcase}... "
              e.deployment_routines.each { |r|
                l.logs "Running #{r.name}... "
                BlackStack::Deployer::add_routine(r.to_hash)
                BlackStack::Deployer::run_routine(n.name, r.name)
                l.done
              }
            l.done
          }
        l.done # Running extensions routines...
      l.done # Deploying pampa node #{}...
    } # BlackStack::Pampa.nodes.each
  l.done # Installing Pampa Nodes...
  
  l.logs 'Deplying Pampa Workers... '
  BlackStack::Pampa.start()
  l.done
end # if parser.value('pampa')


# deploy pampa workers
if parser.value('workmesh')
  # set workmesh logger
  BlackStack::Workmesh.set_logger(l)

  l.logs 'Installing Workmesh Nodes... '
    BlackStack::Workmesh.nodes.select { |n| n.name=~/#{parser.value('nodes')}/ }.each { |n|
      l.logs "Installing Workmesh node #{n.name}... "
      n.deploy
      l.done
    } # BlackStack::Workmesh.nodes.each
  l.done
end # if parser.value('workmesh')
