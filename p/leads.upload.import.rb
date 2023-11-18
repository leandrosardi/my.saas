# MySaaS Emails - Import Ingested CSV of Leads
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#
# This process insert rows into the table eml_upload_leads_row.
# 

# load gem and connect database
require 'app/mysaas'
require 'app/lib/stubs'
require 'app/config'
require 'app/version'
DB = BlackStack::CRDB::connect
require 'app/lib/skeletons'

# add required extensions
BlackStack::Extensions.append :i2p

l = BlackStack::LocalLogger.new('./leads.upload.import.log')

while (true)
    begin
        # active campaigns with jobs pending delivery
        l.logs "Get array of eml_upload_leads_row pending of import... "
        rows = BlackStack::Leads::UploadLeadsRow.where(:import_end_time => nil).all
        l.logf "done (#{rows.size})"

        # number of columns that each line must have
        if rows.size > 0
            l.logs "Get number of columns that each line must have... "
            colcount = rows[0].line.split("\t").size
            l.logf "done (#{colcount})"
        end

        # for each row
        rows.each { |row|
            # flag start time
            l.logs "Flag start time... "
            row.import_start_time = now
            row.save
            l.done

            begin
                # import row
                l.logs "Import row... "
                row.import(colcount, l)
                l.done

                # update eml_upload_leads_job
                # flag start time
                l.logs "Flag end time... "
                row.import_success = true
                row.import_error_description = nil
                row.import_end_time = now
                row.save
                l.done    
            rescue => e
                l.logf "error: #{e.to_console}"

                row.import_success = false
                row.import_error_description = e.message
                row.import_end_time = now
                row.save
            end
        }
    rescue => e
        l.logf "Error: #{e.message}"
    end 

    l.logs 'Sleeping... '
    sleep(120)
    l.done
  end # while (true)