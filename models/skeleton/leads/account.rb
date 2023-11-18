module BlackStack
    module Leads
        class Account < BlackStack::MySaaS::Account
            one_to_many :users, :class=>:'BlackStack::Leads::User', :key=>:id_account

            def exports
                q = "
                    SELECT e.id
                    FROM fl_export e
                    JOIN \"user\" u ON (u.id=e.id_user AND u.id_account='#{self.id}')
                    WHERE e.delete_time IS NULL
                "
                ids = DB[q].all.map{|r| r[:id]}
                BlackStack::Leads::Export.where(:id=>ids).all
            end # def exports

        end # class Account
    end # module Leads
end # module BlackStack