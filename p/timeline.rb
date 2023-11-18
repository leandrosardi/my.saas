# MySaaS Emails - Timeline
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# This script is to keep the table `eml_timeline` updated.

# load gem and connect database
require 'app/mysaas'
require 'app/lib/stubs'
require 'app/config'
require 'app/version'
DB = BlackStack::CRDB::connect
require 'app/lib/skeletons'

l = BlackStack::LocalLogger.new('./timeline.log')

N = 1 # batches of addresses to process. I set it to 1 in order to round robing the shared addresses between the accounts.

while (true)
    begin
        # update timeline
        l.logs "Update addresses timeline... "
        BlackStack::Emails::Address.select(:id, :address).all { |a|
        #BlackStack::Emails::Address.ids_for_stats_update.each { |aid|
            #a = BlackStack::Emails::Address.where(:id=>aid).first
            # update stats
            l.logs "#{a.address}... "
                dt = a.timeline_start_time

                l.logs "Update start_time... "
                a.timeline_start_time=now
                a.save
                l.logf 'done'.green

                begin
                    a.update_timeline(dt, l)
                    
                    # update timeline
                    l.logs "Update end_time... "
                    a.timeline_end_time=now
                    a.timeline_success=true
                    a.save
                    l.logf 'done'.green
                rescue => e
                    l.logf "ERROR: #{e.to_console.to_s.red}"

                    l.logs "Update end_time... "
                    a.timeline_end_time=now
                    a.timeline_success=false
                    a.timeline_error_description=e.message
                    a.save        
                    l.logf 'done'.green
                end

            l.logf 'done'.green
            
            # release resources
            DB.disconnect
            GC.start
        }
        l.logf 'done'.green

        # update stats
        l.logs "Update followups... "
        BlackStack::Emails::Followup.ids_for_stats_update.each { |fid| 
            l.logs "#{fid}... "
            begin
                l.logs "Load followup... "
                f = BlackStack::Emails::Followup.where(:id=>fid).first
                l.logf 'done'.green

                l.logs "Update start_time... "
                f.timeline_start_time=now
                f.save
                l.logf 'done'.green

                l.logs 'Update stats... '
                f.update_stats
                l.logf 'done'.green

                l.logs "Update end_time... "
                f.timeline_end_time=now
                f.timeline_success=true
                f.save
                l.logf 'done'.green
            rescue => e
                l.logs "Update end_time... "
                f.timeline_end_time=now
                f.timeline_success=false
                f.timeline_error_description=e.message
                f.save
                l.logf 'done'.green
            end
            l.logf 'done'.green
        }
        l.logf 'done'.green

        # update stats
        l.logs "Update campaigns... "
        BlackStack::Emails::Campaign.ids_for_stats_update.each { |cid| 
            l.logs "#{cid}... "
            begin
                l.logs "Load campaign... "
                c = BlackStack::Emails::Campaign.where(:id=>cid).first
                l.logf 'done'.green

                l.logs "Update start_time... "
                c.timeline_start_time=now
                c.save
                l.logf 'done'.green

                l.logs 'Update stats... '
                c.update_stats
                l.logf 'done'.green

                l.logs "Update end_time... "
                c.timeline_end_time=now
                c.timeline_success=true
                c.save
                l.logf 'done'.green
            rescue => e
                l.logs "Update end_time... "
                c.timeline_end_time=now
                c.timeline_success=false
                c.timeline_error_description=e.message
                c.save
                l.logf 'done'.green
            end
            l.logf 'done'.green
        }
        l.logf 'done'.green
    rescue => e
        l.logf "Error: #{e.to_console}"
    end 
    
    l.logs 'Sleeping... '
    sleep(60*6) # Update timeline every 6 minutes.
    l.logf 'done'.green
  end # while (true)