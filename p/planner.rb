# MySaaS Emails - Planner
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# README
# 
# In order to [pamperize](https://github.com/leandrosardi/pampa), it must be done at an `account` level.
# That means: each account will run its own planner.
# 
# In order to don't have to manage concurrency on the `shared_addresses` array, shared addresses must be
# assgined to a single accounts during a `leassing period`.
#

=begin
- How to choose the address when f.sequence_number>1 ?
- How to resolve scalability ?
- Push deliveries to micro.emails.delivery, with the calendars of the campaign.
=end


# load gem and connect database
require 'app/mysaas'
require 'app/lib/stubs'
require 'app/config'
require 'app/version'
DB = BlackStack::CRDB::connect
require 'app/lib/skeletons'

require 'app/extensions/i2p/lib/skeletons'
require 'app/extensions/i2p/main'

# add required extensions
BlackStack::Extensions.append :i2p

l = BlackStack::LocalLogger.new('./planner.log')

n = 0 # total number of deliveries created per while(true) loop
while (true)

    # store then number of deliveries left per address
    buff_daily_left = {}

    # reset the number of deliveries created per while(true) loop
    n = 0

    begin
        l.log ''
        
        # Restart followups who planned N hours ago.        
        l.logs 'Restart active followup planned 3 hours ago... '
        q = "
            SELECT id 
            FROM eml_followup f 
            WHERE f.status=#{BlackStack::Emails::Campaign::STATUS_ON} 
            AND f.planning_end_time IS NOT NULL 
            AND f.planning_end_time < CAST('#{now}' AS TIMESTAMP) - INTERVAL '2 hours'
        "
        DB[q].all { |row|
            l.logs "Restarting #{row[:id]}... "
            DB.execute("UPDATE eml_followup SET planning_end_time=NULL WHERE id='#{row[:id]}'")
            l.logf 'done'.green
            GC.start
            DB.disconnect
        }
        l.logf 'done'.green

        # get list of active followups
        # shuffle them in order to get A/B testing working
        l.logs 'load active followups... '
        followups = BlackStack::Emails::Followup.select(
            :id, :id_user, 
            :id_campaign, 
            :name, :subject, 
            :body, :sequence_number, 
            :delay_days
        ).where(
            :delete_time=>nil,
            :status=>BlackStack::Emails::Campaign::STATUS_ON,
#            :planning_end_time=>nil
        ).all.sort_by { |o| o.create_time }
        l.logf "done (#{followups.size})"

        # TODO: If a campaign has been paused or deleted, unassign addresses for all its pending jobs, and mark the job as pending for planning.
        # move backward all the further delivereries assigned to the addresses of the abandoned campaign.

            # For each active followup pending planning, I have to create the jobs.
            followups.each { |followup|
                l.log ''
                l.log "#{followup.user.email}.#{followup.campaign.name}.#{followup.name} (#{followup.id}):"

                    l.logs "Flag planning start... "
                    followup.start_planning
                    l.logf 'done'.green

                    begin
                        l.logs 'Loading Emails account... '
                        a = BlackStack::Emails::Account.where(:id=>followup.user.id_account).first
                        l.logf 'done'.green

                        l.logs 'Loading I2P account... '
                        b = BlackStack::I2P::Account.where(:id=>followup.user.id_account).first
                        l.logf 'done'.green

                        # update account balance
                        BlackStack::I2P::Account.update_balance_snapshot([b.id])

                        # cancel all credits have been consumed 
                        l.logs 'Verify account credits... '
                        credits = 1 # b.credits('deliveries').to_i # Deprecated: delivery credits are not used anymore - We use number of leads instead.
                        if credits < 1
                            l.logf 'No credits left'.yellow
                        else
                            l.logf 'done'.green

                            l.logs 'Verify account daily quota... '
                            daily_quota = a.stop_left.to_i
                            if daily_quota < 1
                                l.logf 'Daily quota exceeded'.yellow
                            else
                                l.logf daily_quota.to_s.green

                                l.logs 'Loading campaign... '
                                campaign = BlackStack::Emails::Campaign.select(:id, :use_public_addresses).where(:id=>followup.id_campaign).first
                                l.logf 'done'.green

                                l.logs 'Loading outreaches... '
                                outreaches = BlackStack::Emails::Outreach.select(:id).where(:id_campaign=>campaign.id).all
                                l.logf 'done'.green

                                l.logs 'Loading users... '
                                user = BlackStack::Emails::User.select(:id, :id_account).where(:id=>followup.id_user).first
                                l.logf 'done'.green

                                l.logs "Load #{daily_quota.to_s} pending leads... "
                                id_leads  = followup.get_ids_of_pending_leads(daily_quota)
                                if id_leads .size == 0
                                    l.logf "No leads found".red
                                else
                                    l.logf "done (#{id_leads .size})"

                                    l.logs "Loading #{daily_quota.to_s} addresses... "
                                    id_addresses = followup.get_id_addresses
                                    if id_addresses.size == 0
                                        l.logf "No addresses found".red
                                    else
                                        l.logf "done (#{id_addresses.size})"
                                        # update the buffer
                                        l.logs "Updating daily quota buffer... "
                                        buff_daily_left = BlackStack::Emails::Address.daily_left_for_planning(id_addresses)
                                        l.logf 'done'.green
                                        # create daily quota deliveries
                                        l.logs "Creating #{id_leads.size.to_s} deliveries... "
                                        j = 0
                                        total = 0 # total deliveries created
                                        while j < id_leads.size
                                            print '.'
                                            o = nil # delivery
                                            # get the lead object
                                            id_lead = id_leads[j]
                                            lead = BlackStack::Leads::Lead.where(:id=>id_lead).first
                                            # get an address with quota
                                            id_address = id_addresses.shuffle.select {
                                                |id_address| buff_daily_left[id_address] > 0
                                            }.first
                                            # exilt the loop
                                            break if id_address.nil?
                                            # create delivery
                                            o = followup.create_delivery(lead, id_address)
                                            # TODO: push delivery to micro.emails.deliveries 
                                            # increase the number of deliveries created
                                            total += 1
                                            n += 1
                                            # decrease quota from the address
                                            buff_daily_left[id_address] -= 1
                                            # next lead
                                            j += 1
                                        end # while 
                                        l.logf total == 0 ? "No deliveries created".yellow : "done (#{total})".green
                                    end # if addresses.size == 0
                                end # if id_leads .size == 0
                            end # if daily_quota < 1
                        end # if credits < 1

                        l.logs "Flag planning end... "
                        followup.end_planning
                        l.logf 'done'.green

                    rescue Exception => e
                        l.logf "Error: #{e.to_console}".red

                        l.logs "Flag planning error... "
                        followup.end_planning(e.message)
                        l.logf 'done'.green
                    end # begin
                #l.logf 'done'.green
            } # followups.each

    rescue => e
        l.logf "Error: #{e.to_console}".red
    end 
    
    l.log ''
    l.logs 'Sleeping... '
    #sleep(3*60) if n==0 # NOTE: planner runs every X hour in order to don't scale the database expenses
    sleep(5*60) # 5-minute sleep
    l.logf 'done'.green
  end # while (true)