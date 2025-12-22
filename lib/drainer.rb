=begin
# Example of @@setup hash descriptor:

```
{
    :batch_size => 1000, # number of records to process by batch

    # custom function to choose accounts to delete
    :account_auto_delete => lambda { |limit: 100, days: 30|
        # select accounts with no recent logins, and no active subscriptions, and no paid accounts in the last 30 days
        DB["
            select 
                a.id, a.name, c.email, a.api_key,
                count(l.id) as recent_logins, 
                count(m.id) as recent_movments
            from \"account\" a
            left join \"user\" c on c.id = a.id_user_to_contact 
            join \"user\" u on a.id = u.id_account
            left join \"login\" l on (
                u.id = l.id_user and
                l.create_time > current_timestamp - interval '#{days.to_s} day'
            )
            left join \"movement\" m on (
                a.id = m.id_account and
                m.create_time > current_timestamp - interval '#{days.to_s} day'
            )
            where a.delete_time is null
            and a.api_key <> '#{SU_API_KEY}' -- never delete the admin
            group by a.id, a.name, c.email, a.api_key
            having 
                count(l.id) = 0 and
                count(m.id) = 0
            limit #{limit.to_s}
        "].all.map { |r| r[:id] }
    },                

    # steps to perform to drain an account
    :steps => [
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
        { table: :rule_instance, action: :unlink, key: :id_rule_instance },
        { table: :rule_instance, action: :delete },
        { table: :rule, action: :delete },
        { table: :trigger, action: :delete },
        { table: :job_cost, action: :delete },
        { table: :job_screenshot, action: :delete },
        { table: :event_picture, action: :delete },
        { table: :event_job, action: :delete },
        { table: :event, action: :delete },
        { table: :job, action: :delete },
        { table: :source, action: :delete },
        { table: :open, action: :delete },
        { table: :click, action: :delete },
        { table: :unsubscribe, action: :delete },
        { table: :link, action: :delete },
        { table: :outreach_cost, action: :delete },
        { table: :outreach_seen, action: :delete },
        { table: :outreach, action: :delete },
        { table: :enrichment_cost, action: :delete },
        { table: :enrichment_screenshot, action: :delete },
        { table: :enrichment_snapshot, action: :delete },
        { table: :enrichment, action: :delete },
        { table: :inboxcheck, action: :delete },
        { table: :connectioncheck, action: :delete },
        { table: :request, action: :delete },
        { table: :import_mapping, action: :delete },
        { table: :import_row, action: :delete },
        { table: :import, action: :delete },
        { table: :filter_country, action: :delete },
        #{ table: :filter_headcount, action: :delete },
        { table: :filter_industry, action: :delete },
        { table: :filter_keyword, action: :delete },
        { table: :filter_location, action: :delete },
        { table: :filter_naics, action: :delete },
        { table: :filter_revenue, action: :delete },
        { table: :filter_sic, action: :delete },
        { table: :filter_tag, action: :delete },
        { table: :trigger, action: :delete },
        { table: :filter, action: :delete },
        { table: :action, action: :delete },
        { table: :lead_data, action: :delete },
        { table: :lead_tag, action: :delete },
        { table: :lead, action: :delete },
        { table: :company_data, action: :delete },
        { table: :company_industry, action: :delete },
        { table: :company_naics, action: :delete },
        { table: :company_sic, action: :delete },
        { table: :company_tag, action: :delete },
        { table: :company, action: :delete },
        { table: :industry, action: :delete },
        { table: :location, action: :delete },
        #{ table: :naics, action: :delete },
        #{ table: :sic, action: :delete },
        { table: :headcount, action: :delete },
        { table: :revenue, action: :delete },
        { table: :inboxcheck, action: :delete },
        { table: :connectioncheck, action: :delete },
        { table: :profile, action: :delete },
        { table: :bulk_action, action: :delete },
        { table: :tag, action: :delete },
        { table: :source_type, action: :delete },
        { table: :enrichment_type, action: :delete },
        { table: :outreach_type, action: :delete },
        { table: :profile_type, action: :delete },
        { table: :channel, action: :delete },
        { table: :data_type, action: :delete },
        { table: :ai_agent, action: :delete },
        { 
            table: :notification, 
            action: :delete, 
            :dataset_function=>
            # custom function to get the dataset to process  
                lambda { |id_account|
                    # join tables notification, user and account to get the notifications
                    DB[:notification].join(:user, id: :id_user).where(Sequel[:user][:id_account] => id_account)
                },
        },
        { table: :api_call, action: :delete },
        { 
            table: :preference, 
            action: :delete, 
            :dataset_function=>
            # custom function to get the dataset to process  
                lambda { |id_account|
                    # join tables notification, user and account to get the notifications
                    DB[:preference].join(:user, id: :id_user).where(Sequel[:user][:id_account] => id_account)
                },
        },
        { 
            table: :user_role, 
            action: :delete, 
            :dataset_function=>
            # custom function to get the dataset to process  
                lambda { |id_account|
                    # join tables notification, user and account to get the notifications
                    DB[:user_role].join(:user, id: :id_user).where(Sequel[:user][:id_account] => id_account)
                },
        },
        { 
            table: :login, 
            action: :delete, 
            :dataset_function=>
            # custom function to get the dataset to process  
                lambda { |id_account|
                    # join tables notification, user and account to get the notifications
                    DB[:login].join(:user, id: :id_user).where(Sequel[:user][:id_account] => id_account)
                },
        },
    ],
    # number of days to keep data in the drainer before deleting them permanently
    :days_to_keep => 7,
}
```
=end

module BlackStack
    module Drainer
        # drainer default setup
        @@setup = {
            # number of records to process by batch
            :batch_size => 1000, 

            # custom function to choose accounts to delete
            :account_auto_delete => lambda { |limit: 100, days: 30|
                # select accounts with no recent logins, and no active subscriptions, and no paid accounts in the last 30 days
                DB["
                    select 
                        a.id, a.name, c.email, a.api_key,
                        count(l.id) as recent_logins, 
                        count(m.id) as recent_movments
                    from \"account\" a
                    left join \"user\" c on c.id = a.id_user_to_contact 
                    join \"user\" u on a.id = u.id_account
                    left join \"login\" l on (
                        u.id = l.id_user and
                        l.create_time > current_timestamp - interval '#{days.to_s} day'
                    )
                    left join \"movement\" m on (
                        a.id = m.id_account and
                        m.create_time > current_timestamp - interval '#{days.to_s} day'
                    )
                    where a.delete_time is null
                    and a.api_key <> '#{SU_API_KEY}' -- never delete the admin
                    group by a.id, a.name, c.email, a.api_key
                    having 
                        count(l.id) = 0 and
                        count(m.id) = 0
                    limit #{limit.to_s}
                "].all.map { |r| r[:id] }
            },                

            # steps to perform to drain an account
            :steps => [
                # one has descriptor for each table to delete and each foraing key to unlink
            ],

            # number of days after setting `account.delete_time` to keep data in the drainer before deleting them permanently
            :days_to_keep => 7,

            # custom code to run after draining an account
            # examples:
            # - call micro-service nodes to delete related data in other systems
            # - delete AWS resources related to the account
            #
            :after_draining_hook => lambda { |id_account, logger: nil|
                l = logger || BlackStack::DummyLogger.new(nil)
                # override this function if you need to run custom code after draining an account  
            }, 
        }

        # getter
        def self.days_to_keep
            return @@setup[:days_to_keep]
        end # getter

        # initialize @@setup hash descriptor
        def self.set(
            batch_size: nil,
            account_auto_delete: nil,
            steps: [],
            days_to_keep: nil
        )
            if batch_size
                # validate: batch_size must be a positive integer
                raise 'batch_size must be a positive integer' unless batch_size.is_a?(Integer)
                @@setup[:batch_size] = batch_size 
            end
            if account_auto_delete
                # validate: account_auto_delete must be a lambda with parameters limit: and days:
                raise 'account_auto_delete must be a lambda with parameters limit: and days:' unless account_auto_delete.is_a?(Proc) && account_auto_delete.parameters.map { |p| p[1] } == [:limit, :days]                
                @@setup[:account_auto_delete] = account_auto_delete
            end
            if steps
                # validate: steps must be an array of valid hash descriptors
                raise 'steps must be an array' unless steps.is_a?(Array)
                errors = []
                steps.each { |step|
                    arr = valid_step?(step)
                    errors << "Step #{step} has the following errors: " + arr.join(", ") if arr.size > 0
                }
                raise "Invalid step descriptor:\n#{errors.join("\n")}" if errors.size > 0
                @@setup[:steps] += steps
            end
            if days_to_keep
                # validate: days_to_keep must be a positive integer
                raise 'days_to_keep must be a positive integer' unless days_to_keep.is_a?(Integer)
                @@setup[:days_to_keep] = days_to_keep
            end
        end # set

        # 
        def self.add_steps(steps=[])
            # validate: steps must be an array of valid hash descriptors
            raise 'steps must be an array' unless steps.is_a?(Array)
            errors = []
            steps.each { |step|
                arr = valid_step?(step)
                errors << "Step #{step} has the following errors: " + arr.join(", ") if arr.size > 0
            }
            raise "Invalid step descriptor:\n#{errors.join("\n")}" if errors.size > 0
            @@setup[:steps] += steps
        end # add_steps

        #
        def self.run(
            logger: nil, 
            auto_deletion_batch_size: 100, 
            auto_deletion_inactivity_days: 30 
        )
            l = logger || BlackStack::DummyLogger.new(nil)
            h = self.to_h

            # load accounts to delete
            accounts_to_delete = h[:account_auto_delete].call(
                limit: auto_deletion_batch_size,
                days: auto_deletion_inactivity_days
            )

            while accounts_to_delete.size > 0
                l.logs "Auto-deleting #{accounts_to_delete.size.to_s.blue} accounts... "
                DB[:account].where(id: accounts_to_delete).update(
                    delete_time: now
                )
                l.logf 'done'.green
                accounts_to_delete = h[:account_auto_delete].call(
                    limit: PARSER.value('auto_deletion_batch_size'), 
                    days: PARSER.value('auto_deletion_inactivity_days')
                )
            end # while

            # Load account object 
            l.logs "Load accounts to drain... "
            #if BlackStack.sandbox?
            #    accounts = BlackStack::MySaaS::Account.where(
            #        Sequel.lit("
            #            delete_time IS NOT NULL AND
            #            delete_time <= NOW() - INTERVAL '#{h[:days_to_keep]} days' --AND
            #            --draining_success IS NULL
            #        ")
            #    ).all
            #else
                accounts = BlackStack::MySaaS::Account.where(
                    Sequel.lit("
                        delete_time IS NOT NULL AND
                        delete_time <= NOW() - INTERVAL '#{h[:days_to_keep]} days' AND
                        draining_success IS NULL
                    ")
                ).all
            #end
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
                            id_column = Sequel.qualify(table, :id)
                            loop do
                                # get a batch of ids to delete
                                batch = ds.select(id_column).limit(z).all
                                break if batch.empty?
                                ids = batch.map { |r| r[id_column] }.compact
                                break if ids.empty?
                                # delete records
                                l.logs "Remaining #{count.to_s.blue}... "
                                DB[table].where(id: ids).delete
                                count -= ids.length
                                l.logf "deleted #{ids.length.to_s.blue}"
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
                            id_column = Sequel.qualify(table, :id)
                            loop do
                                # get a batch of ids to unlink
                                batch = ds.select(id_column).limit(z).all
                                break if batch.empty?
                                ids = batch.map { |r| r[id_column] }.compact
                                break if ids.empty?
                                # unlink records
                                l.logs "Remaining #{count.to_s.blue}... "
                                DB[table].where(id: ids).update(key => nil)
                                count -= ids.length
                                l.logf "unlinked #{ids.length.to_s.blue}"
                            end
                            l.done
                        end # if action 
                    }
                    h[:after_draining_hook].call(a.id, logger: l)
                    a.draining_success = true
                    l.done
                rescue => e
                    l.reset
                    l.log "Error draining account #{a.id.to_s.red}: #{e.to_console.red}"
                    a.draining_success = false
                    a.draining_error_description = e.to_console
                ensure
                    a.save
                end
            }
        end # run

        private

        # return array of errors found in the step hash descriptor
        def self.valid_step?(h)
            # returna value
            ret = []
            # validate: h must be a hash
            ret << 'h must be a hash' unless h.is_a?(Hash)
            # validate: table is required
            ret << 'table is required' unless h.key?(:table)
            # validate: action is required
            ret << 'action is required' unless h.key?(:action)
            # validate: action must be :delete or :unlink
            ret << 'action must be :delete or :unlink' unless [:delete, :unlink].include?(h[:action])
            # if action is :unlink, key is required
            if h[:action] == :unlink
                ret << 'key is required when action is :unlink' unless h.key?(:key)
            end
            return ret
        end # valid_step?

        # return a hash descriptor of the drainer setup
        def self.to_h
            return @@setup
        end # to_h

    end # module Drainer
end # module BlackStack