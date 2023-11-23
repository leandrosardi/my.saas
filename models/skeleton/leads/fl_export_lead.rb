module BlackStack
module Leads
  class ExportLead < Sequel::Model(:fl_export_lead)
    many_to_one :fl_export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
    many_to_one :fl_lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead

    # verify the account has credits before adding a lead to the export.
    # if the account has not credits, then raise an exception 'No Credits'.
    #
    # if the lead has not been added to any other export list of this account, 
    # then consume 1 credit from the account.
    #
    # call the super method to add the lead to the export.
    # 
    def save()
      # if it is a public lead (not owned by me), then 
      # i need credits and it will consume my credits.
      if self.fl_lead.id_user.nil?
        account = BlackStack::I2P::Account.where(:id=>self.fl_export.user.id_account).first
        #raise 'No Credits' if account.credits('leads').to_i < 1        
      end
      
      super()
    end

  end
end
end