# encoding: utf-8
require 'mysaas'
require 'lib/stubs'
#require_relative '/home/leandro/code/my-ruby-deployer/lib/my-ruby-deployer' # enable this line if you want to work with a live version of deployer
#require_relative '/home/leandro/code/blackstack-nodes/lib/blackstack-nodes' # enable this line if you want to work with a live version of nodes
require 'config'
require 'version'

l = BlackStack::LocalLogger.new('./drainer.log')

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

# TODO: place your code here
        #BlackStack::Archiver.run(logger:l)

# Draininng configuration
h = {
    :batch_size => 1000, # number of records to process by batch
    :steps => [
=begin
        # master
        :lease,
        :allocation,
        # update subaccount set id_subscription = null where id_subscription is not null;
        # update subaccount set allocation_success=null where allocation_success is not null; -- no subscription, no allocation
=end
        # I2P - master and slave
        { table: :movement, action: :delete },
        { 
            table: :invoice_item, 
            action: :delete, 
            dataset_function: # custom function to get the dataset to process  
                lambda { |id_account|
                    DB[:invoice_item].join(:invoice, id: :id_invoice).where(Sequel[:invoice][:id_account] => id_account)
                },
        },
        { table: :invoice, action: :delete },
        { table: :subscription, action: :delete },
        #{ table: :buffer_paypal_notification, action: :delete },

        # Slave
        { table: :timeline, action: :delete },
        { table: :trigger, action: :unlink, key: :id_source },
        { table: :trigger, action: :unlink, key: :id_action },
        { table: :trigger, action: :unlink, key: :id_rule },
        { table: :trigger, action: :unlink, key: :id_link },
        { table: :rule, action: :unlink, key: :id_filter },
        { table: :action, action: :unlink, key: :id_filter },
        { table: :enrichment, action: :unlink, key: :id_action },
        { table: :outreach, action: :unlink, key: :id_action },
        { table: :lead_tag, action: :unlink, key: :id_action_create },
        { table: :lead_tag, action: :unlink, key: :id_action_delete },
        { table: :company_tag, action: :unlink, key: :id_action_create },
        { table: :company_tag, action: :unlink, key: :id_action_delete },
        { table: :rule_instance, action: :unlink, key: :id_enrichment },
        { table: :enrichment, action: :unlink, key: :id_rule_instance },
        { table: :outreach, action: :unlink, key: :id_rule_instance },
        { table: :lead_tag, action: :unlink, key: :id_rule_instance_create },
        { table: :lead_tag, action: :unlink, key: :id_rule_instance_delete },
        { table: :company_tag, action: :unlink, key: :id_rule_instance_create },
        { table: :company_tag, action: :unlink, key: :id_rule_instance_delete },
=begin
        :allocation,

        # update profile set id_subaccount=null where id_subaccount is not null;
        :subaccount,
        # update account set premium=false where premium=true;
        :requirement,
        :profile,
        :subaccount,

        :source_type,
        :enrichment_type,
        :outreach_type,
        :profile,
        :profile_type,
        :channel,
=end
    ],
    # number of days to keep data in the drainer before deleting them permanently
    :days_to_keep => 7,
}

#binding.pry

        # Load account object 
        l.logs "Load accounts to drain... "
        if BlackStack.sandbox?
            accounts = BlackStack::MySaaS::Account.where(
                Sequel.lit("
                    delete_time IS NOT NULL AND
                    delete_time <= NOW() - INTERVAL '#{h[:days_to_keep]} days' --AND
                    --draining_success IS NULL
                ")
            ).all
        else
            accounts = BlackStack::MySaaS::Account.where(
                Sequel.lit("
                    delete_time IS NOT NULL AND
                    delete_time <= NOW() - INTERVAL '#{h[:days_to_keep]} days' AND
                    draining_success IS NULL
                ")
            ).all
        end
        l.done(details: accounts.length.to_s.blue)

        accounts.each { |a|
            l.logs "Draining account #{a.id.to_s.blue}... "
            begin
                z = h[:batch_size]
                h[:steps].each { |step|
                    table = step[:table]
                    action = step[:action]
                    dataset_function = step[:dataset_function]
                    if action == :delete
                        l.logs "Deleting #{table.to_s.blue}... "
                        if dataset_function
                            # use custom function to get the dataset
                            ds = dataset_function.call(a.id)
                        else
                            # use default dataset
                            ds = DB[table].where(id_account: a.id)
                        end
                        count = ds.count
                        loop do
                            # get a batch of records to delete
                            records = ds.limit(z).all
                            break if records.length == 0
                            # delete records
                            l.logs "Remaining #{count.to_s.blue}... "
                            DB[table].where(id: records.map { |r| r[:id] }).delete
                            count -= records.length
                            l.logf "deleted #{records.length.to_s.blue}"
                        end
                        l.done
                    elsif action == :unlink
                        key = step[:key]
                        l.logs "Unlinking #{table.to_s.blue}.#{key.to_s.blue}... "
                        if dataset_function
                            # use custom function to get the dataset
                            ds = dataset_function.call(a.id)
                        else
                            # use default dataset
                            ds = DB[table].where(Sequel.lit("#{key} IS NOT NULL AND id_account = '#{a.id.to_s}'"))
                        end
                        count = ds.count
                        loop do
                            # get a batch of records to unlink
                            records = ds.limit(z).all
                            break if records.length == 0
                            # unlink records
                            l.logs "Remaining #{count.to_s.blue}... "
                            DB[table].where(id: records.map { |r| r[:id] }).update(key => nil)
                            count -= records.length
                            l.logf "unlinked #{records.length.to_s.blue}"
                        end
                        l.done
                    end # if action 
                }
                a.draining_success = true
                l.done

            rescue => e
                l.reset
                l.log "Error draining account #{a.id.to_s.red}: #{e.to_console.red}"
                a.draining_success = false
                a.draining_error_description = e.to_console
binding.pry
            ensure
                a.save
            end
        }

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

