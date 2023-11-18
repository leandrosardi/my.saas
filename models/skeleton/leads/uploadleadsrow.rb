module BlackStack
    module Leads
        class UploadLeadsRow < Sequel::Model(:eml_upload_leads_row)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Leads::UploadLeadsJob', :key=>:id_upload_leads_job
            many_to_one :lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead

            def to_hash
                h = {}
                row = self
                job = row.uploadleadsjob
                vals = row.line.split("\t")
                h['id_user'] = uploadleadsjob.id_user
                h['datas'] = []
                i = 0
                vals.each { |val|
                    # 
                    val.strip!
                    # get the mapping definition
                    m = job.uploadleadsmappings.select { |m| m.column == i }.first
                    # map the value to the lead
                    if m.data_type.to_i == BlackStack::Leads::Data::TYPE_CUSTOM
                        h['datas'] << { 'type' => m.data_type, 'custom_field_name' => m.custom_field_name, 'value' => val }
                    elsif m.data_type.to_i == BlackStack::Leads::Data::TYPE_COMPANY_NAME                       
                        h['company'] = { 'name' => val }
                    elsif (
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_FIRST_NAME ||
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_LAST_NAME
                    )
                        fname_mapping = job.uploadleadsmappings.select { |m| m.data_type.to_i == BlackStack::Leads::Data::TYPE_FIRST_NAME }.first
                        lname_mapping = job.uploadleadsmappings.select { |m| m.data_type.to_i == BlackStack::Leads::Data::TYPE_LAST_NAME }.first
                        fname = fname_mapping.nil? ? '' : vals[fname_mapping.column]
                        lname = lname_mapping.nil? ? '' : vals[lname_mapping.column]
                        h['name']  = "#{fname} #{lname}"
                    elsif m.data_type.to_i == BlackStack::Leads::Data::TYPE_LOCATION
                        h['location']  = val
                    elsif m.data_type.to_i == BlackStack::Leads::Data::TYPE_INDUSTRY
                        h['industry'] = val
                    elsif ( 
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_PHONE ||
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_EMAIL ||
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_FACEBOOK ||
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_TWITTER ||
                        m.data_type.to_i == BlackStack::Leads::Data::TYPE_LINKEDIN
                    )
                        # create the data
                        h['datas'] << { 'type' => m.data_type, 'value' => val }
                    end
                    # increase the cell counter
                    i += 1
                }
                h
            end # def to_hash

            def verify_email_addresses(log=nil)
                log = BlackStack::DummyLogger.new if log.nil?
                # find all the mappings for an email address
                log.logs "Getting list of email mappings... "
                mappings = self.uploadleadsjob.uploadleadsmappings.select { |m| m.data_type == BlackStack::Leads::Data::TYPE_EMAIL }
                log.logf "done (#{mappings.size})"

                mappings.each { |m|
                    # get the email address from the row
                    email = self.line.split("\t")[m.column]
                    # validate the email address
                    log.logs "Validating email address #{email}... "
                    if BlackStack::Emails.verify(email)
                        log.yes
                        return true
                    else
                        log.no
                    end 
                }
                return false
            end

            def import(colcount, l=nil)
                l = BlackStack::DummyLogger.new if l.nil?
                row = self
                job = row.uploadleadsjob
                
                # validate number of columns on each row
                l.logs "Validate number of columns... "
                if row.line.split("\t").size != colcount
                    l.logf "error (#{row.split("\t").size} != #{colcount})"
                    raise 'Invalid number of columns'
                else
                    l.done
                end

                # TODO: validate format of standard fields on each rowverify email address

                # validate the email is verified
                #raise 'Invalid email addresses' if !self.verify_email_addresses(l)

                # create the lead object
                # save the lead
                l.logs "Merging new lead... "
                lead = BlackStack::Leads::Lead.merge(self.to_hash)
                lead.save
                l.done

                # link this row to the lead.
                # note: it may be a new lead or an existing lead.
                # note: many rows may point to the same lead.
                self.id_lead = lead.id
                self.save

                # add lead to the export list
                l.logs "Adding lead to export list... "
                self.uploadleadsjob.export.add(lead)
                l.done
      
            end # def import
        end # class UploadLeadsRow
    end # Emails
end # BlackStack