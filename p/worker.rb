# MySaaS - Pampa Worker
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# TODO: dfy-leads extension should require leads extension as a dependency
require 'extensions/i2p/lib/skeletons'
require 'extensions/i2p/main'

require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/emails/lib/skeletons'
require 'extensions/emails/main'

require 'extensions/scraper/lib/skeletons'
require 'extensions/scraper/main'

require 'extensions/dfy-leads/lib/skeletons'
require 'extensions/dfy-leads/main'

# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :leads
BlackStack::Extensions.append :emails
BlackStack::Extensions.append :scraper
BlackStack::Extensions.append :'dfy-leads'

# parse command line parameters
PARSER = BlackStack::SimpleCommandLineParser.new(
    :description => 'This script starts an infinite loop. Each loop will look for a task to perform. Must be a delay between each loop.',
    :configuration => [{
        :name=>'delay',
        :mandatory=>false,
        :default=>30, 
        :description=>'Minimum delay between loops. A minimum of 10 seconds is recommended, in order to don\'t hard the database server. Default is 30 seconds.', 
        :type=>BlackStack::SimpleCommandLineParser::INT,
    }, {
        :name=>'debug', 
        :mandatory=>false,
        :default=>false, 
        :description=>'Activate this flag if you want to require the `pampa.rb` file from the same Pampa project folder, insetad to require the gem as usual.', 
        :type=>BlackStack::SimpleCommandLineParser::BOOL,
    }, {
        :name=>'pampa', 
        :mandatory=>false,
        :default=>'$HOME/code/pampa/lib/pampa.rb', 
        :description=>'Ruby file to require where `debug` is activated.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
    }, {
        :name=>'config', 
        :mandatory=>false,
        :default=>'$HOME/code/mysaas/config.rb', 
        :description=>'Ruby file where is defined the connection-string and jobs.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
    }, {
        :name=>'id', 
        :mandatory=>true, 
        :description=>'Write here a unique identifier for the worker.', 
        :type=>BlackStack::SimpleCommandLineParser::STRING,
    }]
)

# creating logfile
l = BlackStack::LocalLogger.new('worker.'+PARSER.value('id').to_s+'.log')

begin
    # log the paramers
    l.log 'STARTING WORKER'

    # show the parameters
    # TODO: replace this hardocded array for method `PARSER.params`.
    # reference: https://github.com/leandrosardi/simple_command_line_parser/issues/7
    #['id','delay','debug','pampa','config'].each { |param| l.log param + ': ' + PARSER.value(param).to_s }

    # require the pampa library
    l.logs 'Requiring pampa (debug='+(PARSER.value('debug') ? 'true' : 'false')+', pampa='+PARSER.value('pampa')+')... '
    require 'pampa' if !PARSER.value('debug')
    require PARSER.value('pampa') if PARSER.value('debug')
    l.done

    # requiore the config.rb file where the jobs are defined.
    l.logs 'Requiring config (config='+PARSER.value('config')+')... '
    require PARSER.value('config')
    l.done

    #require 'config'
    DB = BlackStack::CRDB::connect
    require 'lib/skeletons'

    # getting the worker object
    worker = BlackStack::Pampa.workers.select { |w| w.id == PARSER.value('id') }.first
    raise 'Worker '+PARSER.value('id')+' not found.' if worker.nil?

    # start the loop
    while true
        # get the start loop time
        l.logs 'Starting loop... '
        start = Time.now()
        l.done        

        begin
            l.log ''
            l.logs 'Starting cycle... '

            BlackStack::Pampa.jobs.each { |job|
                task = nil
                begin
                    l.logs 'Processing job '+job.name+'... '
                    tasks = job.occupied_slots(worker)
                    l.logf tasks.size.to_s+' tasks in queue.'

                    tasks.each { |t|
                        task = t
                        
                        l.logs 'Flag task '+job.name+'.'+task[job.field_primary_key.to_sym].to_s+' started... '
                        job.start(task)
                        l.done

                        l.logs 'Processing task '+task[job.field_primary_key.to_sym].to_s+'... '
                        job.processing_function.call(task, l, job, worker)
                        l.done

                        l.logs 'Flag task '+job.name+'.'+task[job.field_primary_key.to_sym].to_s+' finished... '
                        job.finish(task)
                        l.done
                    }    
                # note: this catches the CTRL+C signal.
                # note: this catches the `kill` command, ONLY if it has not the `-9` option.
                rescue SignalException, SystemExit, Interrupt => e
                    l.logs 'Flag task '+job.name+'.'+task[job.field_primary_key.to_sym].to_s+' interrumpted... '
                    job.finish(task, e)
                    l.done
                        
                    l.logf 'Bye!'

                    raise e

                rescue => e
                    l.logs 'Flag task '+job.name+'.'+task[job.field_primary_key.to_sym].to_s+' failed... '
                    job.finish(task, e)
                    l.done

                    l.logf 'Error: '+e.to_console                
                end        
            }

            l.done

        rescue => e
            l.logf 'Error: '+e.message
        end

        # get the end loop time
        l.logs 'Ending loop... '
        finish = Time.now()
        l.done
        
        # get different in seconds between start and finish
        # if diff > 30 seconds
        l.logs 'Calculating loop duration... '
        diff = finish - start
        l.logf 'done ('+diff.to_s+')'

        if diff < PARSER.value('delay')
            # sleep for 30 seconds
            n = PARSER.value('delay')-diff
                
            l.logs 'Sleeping for '+n.to_label+' seconds... '
            sleep n
            l.done
        else
            l.log 'No sleeping. The loop took '+diff.to_label+' seconds.'
        end
    end # while true
rescue SignalException, SystemExit, Interrupt
    # note: this catches the CTRL+C signal.
    # note: this catches the `kill` command, ONLY if it has not the `-9` option.
    l.logf 'Process Interrumpted.'
rescue => e
    l.logf 'Fatal Error: '+e.to_console
rescue 
    l.logf 'Unknown Fatal Error.'
end