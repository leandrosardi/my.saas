# MySaaS Emails - Deletion
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

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
    begin
        l.log ''

        # deleted pending deliveries of paused followups
        # deleted pending deliveries of deleted addresses
        # deleted pending deliveries of disabled addresses
        # deleted pending deliveries of unshared addresses
        # TODO: delete pending deliveres of tag-removed addresses
        # TODO: deleted failed deliveries (more than 3 failures)
        l.logs 'Delete pending deliveries... '
        q = "
            SELECT d.id
            FROM eml_delivery d
            JOIN eml_followup f ON (
                f.id=d.id_followup
                AND
                f.status<>#{BlackStack::Emails::Campaign::STATUS_ON}
            )
            WHERE d.delivery_end_time IS NULL
            and coalesce(d.is_response,false) = false
            and d.delete_time is null
        UNION ALL
            SELECT d.id
            FROM eml_delivery d
            JOIN eml_address a ON (
                a.id=d.id_address
                AND
                a.delete_time IS NOT NULL
            )
            WHERE d.delivery_end_time IS NULL
            and coalesce(d.is_response,false) = false
            and d.delete_time is null
        UNION ALL
            SELECT d.id
            FROM eml_delivery d
            JOIN eml_address a ON (
                a.id=d.id_address
                AND
                COALESCE(a.enabled, FALSE) = FALSE
            )
            WHERE d.delivery_end_time IS NULL
            and coalesce(d.is_response,false) = false
            and d.delete_time is null
        UNION ALL
            SELECT d.id
            FROM eml_delivery d
        JOIN eml_followup f ON f.id=d.id_followup
        JOIN \"user\" u1 ON (u1.id=f.id_user)
            JOIN eml_address a ON a.id=d.id_address
        JOIN \"user\" u2 ON (u2.id=a.id_user)
            WHERE u1.id_account<>u2.id_account
            AND COALESCE(a.shared, FALSE) = FALSE
            AND d.delivery_end_time IS NULL
            and coalesce(d.is_response,false) = false
            and d.delete_time is null
        "
        DB[q].all { |row|
            l.logs "Deleting #{row[:id]}... "
            DB.execute("UPDATE eml_delivery SET delete_time=CAST('#{now}' AS TIMESTAMP) WHERE id='#{row[:id]}'")
            l.done
            GC.start
            DB.disconnect
        }
        l.done
    rescue => e
        l.logf "Error: #{e.to_console}".red
    end 
    
    l.log ''
    l.logs 'Sleeping... '
    #sleep(3*60) if n==0 # NOTE: planner runs every X hour in order to don't scale the database expenses
    sleep(3*60*60) # 5-minute sleep
    l.done
  end # while (true)