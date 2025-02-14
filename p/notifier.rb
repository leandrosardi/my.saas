# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/my-ruby-deployer/lib/my-ruby-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

l = BlackStack::LocalLogger.new('./notifier.log')

l.log "Sandbox mode: #{BlackStack.sandbox? ? 'yes'.green : 'no'.red }"

l.logs 'Connecting the database... '
DB = BlackStack.db_connect
l.logf 'done'.green

l.logs 'Loading models... '
require 'lib/skeletons'
l.logf 'done'.green

# parse command line parameters
PARSER = BlackStack::SimpleCommandLineParser.new(
    :description => 'This script starts an infinite loop. Each loop will look for a task to perform. Must be a delay between each loop.',
    :configuration => [{
        :name=>'delay',
        :mandatory=>false,
        :default=>10, # 25 seconds 
        :description=>'Minimum delay between loops. A minimum of 10 seconds is recommended, in order to don\'t hard the database server. Default is 30 seconds.', 
        :type=>BlackStack::SimpleCommandLineParser::INT,
    }]
)

# loop
while true
    begin
        # get the start loop time
        l.logs 'Starting loop... '
        start = Time.now()
        l.logf 'done'.green       

        BlackStack::Notifications.run(logger:l)

        # get the end loop time
        l.logs 'Ending loop... '
        finish = Time.now()
        l.logf 'done'.green
                
        # get different in seconds between start and finish
        # if diff > 30 seconds
        l.logs 'Calculating loop duration... '
        diff = finish - start
        l.logf 'done'.green + ' ('+diff.to_s+')'

        if diff < PARSER.value('delay')
            # sleep for 30 seconds
            n = PARSER.value('delay')-diff
                    
            l.logs 'Sleeping for '+n.to_label+' seconds... '
            sleep n
            l.logf 'done'.green
        else
            l.log 'No sleeping. The loop took '+diff.to_label+' seconds.'
        end

    rescue SignalException, SystemExit, Interrupt
        l.reset
        # note: this catches the CTRL+C signal.
        # note: this catches the `kill` command, ONLY if it has not the `-9` option.
        l.log 'Process Interrumpted.'
        exit(0)
    rescue => e
        l.reset
        l.log 'Fatal Error: '+e.to_console
        
        l.logf 'Sleeping for 10 seconds... '
        sleep(10)
        l.logf 'done'.green
    end
end # while true

