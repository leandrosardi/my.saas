# MySaaS Emails - Ingest Uploaded CSV of Leads
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

l = BlackStack::LocalLogger.new('./leads.upload.ingest.log')

while (true)
    i = 0
    begin
        # active jobs, pending pending of ingestion
        l.logs "Get array of actiive eml_upload_leads_job pending of ingestion... "
        jobs = BlackStack::Leads::UploadLeadsJob.where(:ingest_success => nil).all
        l.logf "done (#{jobs.size.to_s.blue})"

        # for each job
        jobs.each { |j|
            i += 1

            l.logs "Ingest job #{j.id.blue}... "
            # 
            j.ingest_start_time = now
            j.save
            # 
            begin                
                j.ingest(l)
                # 
                j.ingest_end_time = now
                j.ingest_success= true
                j.ingest_error_description = nil
                j.save
                #
                l.logf 'done'.green
            rescue => e
                #
                j.ingest_end_time = now
                j.ingest_success= false
                j.ingest_error_description = e.to_s
                j.save
                #
                l.logf e.to_s
            end
        } # jobs.each
    rescue => e
        l.logf "Error: #{e.message.to_s.red}"
    end 
    
    l.logs 'Sleeping... '
    if i == 0
        sleep(60*5)
        l.logf 'done'.green
    else
        l.no
    end 
end # while (true)