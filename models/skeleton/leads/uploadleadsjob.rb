module BlackStack
    module Leads
        class UploadLeadsJob < Sequel::Model(:eml_upload_leads_job)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :uploadleadsmappings, :class=>:'BlackStack::Leads::UploadLeadsMapping', :key=>:id_upload_leads_job
            one_to_many :uploadleadsrows, :class=>:'BlackStack::Leads::UploadLeadsRow', :key=>:id_upload_leads_job

            # return true if exists at least one row in the table `eml_upload_leads_row` with the same id_upload_leads_job
            def ingested?
                return true if DB["select count(*) as c from eml_upload_leads_row where id_upload_leads_job = '#{self.id.to_guid}'"].first[:c] > 0
                return false
            end

            # insert a records in the table `eml_upload_leads_row`
            # this function cannot be called by more than one process at the same time.
            def ingest(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                job = self

                # verify the file has not been already ingested.
                log.logs "Already ingested?... "
                if job.ingested? 
                    log.logf 'yes'.yellow
                else
                    log.logf 'no'.green

                    # TODO: vaidate the file has not more than `batchsize` lines.

                    # download file from https://connectionsphere.com/clients/95748517-738c-4f7e-bae4-a98285d91984/emails.leads.uploads/ba2a3baf-669c-475c-9a8c-50ccd4f8f6b6.csv
                    # to /tmp/ba2a3baf-669c-475c-9a8c-50ccd4f8f6b6.csv
                    # and upload to CRDB Cloud
                    log.logs "Download CSV from CS Cloud..."
                    tempfile = "/tmp/#{self.id.to_guid}.csv"
                    # write the file
                    File.open(tempfile, 'w') { |f| f.write(self.csv_content) }
                    log.logf 'done'.green

                    # import to the userfile of CRDB
                    log.logs "Upload CSV to CRDB Cloud..."
                    command = "cockroach userfile upload #{tempfile} --url \"#{BlackStack::CRDB.connection_string_2}\""
                    res = `#{command}`
                    log.logf 'done'.green

                    # delete temp file
                    log.logs "Delete temp file..."
                    command = "rm #{tempfile}"
                    res = `#{command}`
                    log.logf 'done'.green

                    # truncate the temp table
                    log.logs "Trucating temp table..."
                    command = "truncate table eml_upload_leads_row_aux;"
                    DB.execute(command)
                    log.logf 'done'.green

                    # import all files to the database,
                    # making the 3 queries below in a single transaction.
                    # update the id, id_file of all lines
                    log.logs "Ingesting file to temp table..."
                    command = "import into eml_upload_leads_row_aux (\"line\") DELIMITED data('userfile:///#{self.id.to_guid}.csv') with fields_terminated_by=E'\\b', fields_enclosed_by='';"
                    DB.execute(command)
                    log.logf 'done'.green

                    log.logs "Updating the temp table..."
                    command = "update eml_upload_leads_row_aux set id=gen_random_uuid(), id_upload_leads_job='#{self.id.to_sql}';"
                    DB.execute(command)
                    log.logf 'done'.green

                    log.logs "Map temp table to final table..."
                    command = "insert into eml_upload_leads_row (id, id_upload_leads_job, \"line\") select id, id_upload_leads_job, \"line\" from eml_upload_leads_row_aux;"
                    DB.execute(command)
                    log.logf 'done'.green

                    log.logs "Truncating again the temp table..."
                    command = "truncate table eml_upload_leads_row_aux;"
                    DB.execute(command)
                    log.logf 'done'.green

                    # update the number of each line
                    log.logs "Updating row numbers (may take some minutes)... "
                    rownum = 0
                    DB["select id from eml_upload_leads_row where \"line_number\" is null and id_upload_leads_job = '#{self.id.to_guid}'"].all { |r|
                        DB["update eml_upload_leads_row set \"line_number\" = #{rownum.to_s} where id='#{r[:id]}' and \"line_number\" is null limit 1"].all
                        rownum += 1
                        #print '.'
                    }
                    log.logf 'done'.green
                end
            end # def ingest
        end # class UploadLeadsJob
    end # Emails
end # BlackStack