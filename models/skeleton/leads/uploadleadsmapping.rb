module BlackStack
    module Leads
        class UploadLeadsMapping < Sequel::Model(:eml_upload_leads_mapping)
            many_to_one :uploadleadsjob, :class=>:'BlackStack::Leads::UploadLeadsJob', :key=>:id_upload_leads_job
            
        end # class UploadLeadsMapping
    end # Emails
end # BlackStack