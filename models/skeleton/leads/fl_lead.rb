module BlackStack
module Leads
  class Lead < Sequel::Model(:fl_lead)
    many_to_one :user, :class=>:'BlackStack::Leads::User', :key=>:id_user
    many_to_one :fl_company, :class=>:'BlackStack::Leads::Company', :key=>:id_company
    many_to_one :fl_industry, :class=>:'BlackStack::Leads::SearchIndustry', :key=>:id_industry
    many_to_one :fl_location, :class=>:'BlackStack::Leads::SearchLocation', :key=>:id_location
    one_to_many :fl_datas, :class=>:'BlackStack::Leads::Data', :key=>:id_lead
    one_to_many :fl_reminders, :class=>:'BlackStack::Leads::Reminder', :key=>:id_lead
    one_to_many :fl_export_leads, :class=>'BlackStack::Leads::ExportLead', :key=>:id_lead

    # return true if the lead is in any export list belonging to the account
    # return false otherwise
    def exported_by?(account)
      q = "
        SELECT COUNT(*) AS count
        FROM fl_export_lead
        INNER JOIN fl_export ON fl_export.id = fl_export_lead.id_export
        WHERE fl_export.id_user in ('#{account.users.map{|u| u.id}.join("','")}')
        AND fl_export_lead.id_lead = '#{self.id}'
      "
      DB[q].first[:count].to_i > 0
    end

    def update_stat_fields
      # fl_lead.stat_has_email
      self.stat_has_email = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_EMAIL}.size>0
      # fl_lead.stat_has_phone
      self.stat_has_phone = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_PHONE}.size>0
      # fl_lead.stat_verified
      self.stat_verified = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_EMAIL && d.verified}.size>0
      # fl_lead.stat_trust_rate
      self.stat_trust_rate = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_EMAIL}.map{|d| d.trust_rate.to_i}.max 
      # fl_lead.stat_industry_name
      self.stat_industry_name = self.fl_industry.name if self.fl_industry
      # fl_lead.stat_location_name
      self.stat_location_name = self.fl_location.name if self.fl_location
      # fl_lead.stat_company_name
      self.stat_company_name = self.fl_company.name if self.fl_company
      # fl_lead.stat_naics_code
      self.stat_naics_codes = self.fl_company.naics_codes if self.fl_company
      # fl_lead.stat_sic_code
      self.stat_sic_codes = self.fl_company.sic_codes if self.fl_company
      # fl_lead.stat_revenue
      self.stat_revenue = self.fl_company.fl_revenue.name if self.fl_company && self.fl_company.fl_revenue
      # fl_lead.stat_headcount
      self.stat_headcount = self.fl_company.fl_headcount.name if self.fl_company && self.fl_company.fl_headcount
      # fl_lead.stat_personal_verified_email
#binding.pry
      self.stat_personal_verified_email = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_EMAIL && d.verified && d.value.to_s.email? && d.value.to_s.personal_email?}.size>0
      # fl_lead.stat_corporate_verified_email
      self.stat_corporate_verified_email = self.fl_datas.select{|d| d.delete_time.nil? && d.type==BlackStack::Leads::Data::TYPE_EMAIL && d.verified && d.value.to_s.email? && !d.value.to_s.personal_email?}.size>0
      # release resources
      GC.start
      DB.disconnect
    end

    def after_create
      super
      update_stat_fields
    end

    def after_update
      super
      update_stat_fields
    end

    # get all the extensions
    def exports
      self.fl_export_leads.map{|e| e.fl_export}
    end

    def emails
      self.fl_datas.select { |d| d.type == BlackStack::Leads::Data::TYPE_EMAIL }
    end
    
    def phones
      self.fl_datas.select { |d| d.type == BlackStack::Leads::Data::TYPE_PHONE }
    end

    def linkedins
      self.fl_datas.select { |d| d.type == BlackStack::Leads::Data::TYPE_LINKEDIN }
    end

    # validate the strucutre of the hash descritpor.
    # return an arrow of strings with the errors found. 
    def self.validate_descriptor(h)
      errors = []

      # validate: h must be a hash
      errors << "Descriptor must be a hash. Received: #{h.to_s}" if !h.is_a?(Hash)

      if h.is_a?(Hash)
        # validate: :name is required
        errors << "Descriptor must have a :name (#{h})" if !h.has_key?('name')

        # validate: :name is a string
        errors << "Descriptor :name must be a string" if h.has_key?('name') && !h['name'].is_a?(String)

        # validate: if :company is a hash, validate it
        errors += BlackStack::Leads::Company::validate_descriptor(h['company']) if h.has_key?('company') && h['company'].is_a?(Hash)

        # validate: :industry is string or is nil
        errors << "Descriptor :industry must be a string or nil" if !h['industry'].is_a?(String) && !h['industry'].nil?

        # validate: if :industry is a string, validate it
        if h.has_key?('industry') && h['industry'].is_a?(String)
          errors += BlackStack::Leads::Industry::validate_descriptor({ 'name' => h['industry'] })
        end

        # validate: :location is string or is nil
        errors << "Descriptor :location must be a string or nil" if !h['location'].is_a?(String) && !h['location'].nil?

        # validate: if :location is a string, validate it
        if h.has_key?('location') && h['location'].is_a?(String)
          errors += BlackStack::Leads::Location::validate_descriptor({ 'name' => h['location'] })
        end

        # validate: :datas is required
        # deprecated: leads uploaded for appending may not have datas
        #errors << "Descriptor must have a :datas (#{h})" if !h.has_key?('datas')

        # validate: :datas is an array of hashes
        errors << "Descriptor :datas must be an array of hashes" if h['datas'].is_a?(Array) && h['datas'].select{|d| !d.is_a?(Hash)}.size>0

        # validate: :datas must have at least 1 email
        # deprecated: leads uploaded for appending may not have datas
        #errors << "Descriptor :datas must have at least 1 email (#{h['datas'].to_s})" if h['datas'].is_a?(Array) && h['datas'].select{|d| d['type']==BlackStack::Leads::Data::TYPE_EMAIL}.size==0

        # validate: if :id_user is present, it must be a guid
        errors << "Descriptor :id_user must be a guid" if h.has_key?('id_user') && !h['id_user'].guid?

        # validate: if :datas is an array, then validate each element of the array
        if h.has_key?('datas') && h['datas'].is_a?(Array)
          h['datas'].each do |d|
            errors += BlackStack::Leads::Data::validate_descriptor(d)
          end
        end

        if BlackStack::Extensions.exists?(:'dfy-leads')
          # Validate: if :linkedin_picture_url exists, it must be a string
          if h.has_key?('linkedin_picture_url') && !h['linkedin_picture_url'].is_a?(String)
            errors << ":linkedin_picture_url must be a string. Received: #{h['linkedin_picture_url'].to_s}"
          end
  
          # Validate: if :picture_url exists, it must be a string
          if h.has_key?('picture_url') && !h['picture_url'].is_a?(String)
            errors << ":picture_url must be a string. Received: #{h['picture_url'].to_s}"
          end
        end
      end # if h.is_a?(Hash)

      # return the errors found.
      errors
    end

    # what happen if the lead works in more than 1 company (example: founder of 2 companies) --> create 2 records
    def initialize(h)
      super()
      errors = BlackStack::Leads::Lead.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid()
      self.create_time = now
      self.update(h)
    end

    # get estimated first name
    def first_name
      self.name.split(/[^a-zA-Z]/)[0]
    end

    # get estimated last name
    def last_name
      self.name.split(/[^a-zA-Z]/)[-1]
    end

    # save the company.
    # save the lead itself.
    # save each data.
    # save each insight.
    def save
      self.fl_company.save if !self.fl_company.nil?
      super
      self.fl_datas.each { |d|
        d.id_lead = self.id 
        d.save 
      }
    end

    # map the name attribues name, position, industry, location to the model.
    # if exsits a company with the same url, then use it. otherwise, create a new company.
    # add the datas to the exisitig ones.
    # 
    # Return the lead object with its fields updated.
    #
    # The object is not saved into the database. You have to do that after calling this method.
    # 
    def update(h)
      self.name = h['name']
      self.position = h['position']

      # update the user owner of the lead
      # if id_user.nil?, then the lead is public
      self.id_user = h['id_user'] if h.has_key?('id_user')

      # if exsits a company with the same url, then use it.
      if h['company'].is_a?(Hash)
        self.fl_company = BlackStack::Leads::Company.merge(h['company'])
      end

      # map the BlackStack::Leads::Industry to the model.
      if h['industry'].is_a?(String)
        self.fl_industry = BlackStack::Leads::Industry.where(:name=>h['industry']).first 
      end # if h['industry'].is_a?(String)

      # map the FlLocation to the model.
      # reference: https://github.com/ConnectionSphere/leads/issues/33
      if h['location'].is_a?(String)
        o = BlackStack::Leads::Location.where(:name=>h['location']).first
        if !o.nil?
          self.fl_location = o 
        else
          self.stat_location_name = h['location']
        end
      end
#binding.pry
      # if :data is an array, then add each data which value does not exist in the existing ones.
      if h['datas'].is_a?(Array)
        h['datas'].each do |d|
          #d['value'].downcase! # URLs may be case sensitive. Do not downcase them.
          d['id_lead'] = self.id
          self.fl_datas << BlackStack::Leads::Data.merge(d)
        end
      end

      if BlackStack::Extensions.exists?(:'dfy-leads')
        self.linkedin_picture_url = h['linkedin_picture_url']
        self.picture_url = h['picture_url']
        self.stat_city_name = h['city']
        self.stat_state_name = h['state']
        self.stat_country_name = h['country']
        self.stat_area_name = h['area']  
      end

      # update the stat fields of the lead, in order to parform searches faster, by querying one single table.
      self.update_stat_fields
    end # def update(h)

    # if descriptor has one or more emails, then 
    #   build an array of exisiting lead ids, with one or more of the emails in the descriptor.
    #   if h[:id_user] is present, then search only for leads with the same id_user.
    # Return array of IDs found.
    def self.ids_of_existing_leads(h, l=nil)
      errors = BlackStack::Leads::Lead.validate_descriptor(h)
      raise "Errors found (#{errors.size.to_s}):\n#{errors.join("\n")}" if errors.size>0

      # create log object
      l = BlackStack::DummyLogger.new(nil) if l.nil?

      # build an array of exisiting lead ids, with one or more of the emails in the descriptor.
      ids = []

      l.logs "Get emails in descriptor... "
      email_datas = h['datas'].is_a?(Array) ? h['datas'].select { |d| d['type'] == BlackStack::Leads::Data::TYPE_EMAIL } : []
      l.logs "done (#{email_datas.size.to_s})"

      l.logs "Get facebooks in descriptor... "
      fb_datas = h['datas'].is_a?(Array) ? h['datas'].select { |d| d['type'] == BlackStack::Leads::Data::TYPE_FACEBOOK } : []
      l.logs "done (#{email_datas.size.to_s})"

      l.logs "Get linkedins in descriptor... "
      ln_datas = h['datas'].is_a?(Array) ? h['datas'].select { |d| d['type'] == BlackStack::Leads::Data::TYPE_LINKEDIN } : []
      l.logs "done (#{email_datas.size.to_s})"

      if email_datas.size>0
        l.logs "Get leads with the same emails... "
        ids += BlackStack::Leads::Data.where(
          :type => [BlackStack::Leads::Data::TYPE_EMAIL],
          :value => email_datas.map { |d| d['value'] } 
        ).all.map{ |d| 
          d.id_lead
        }.uniq
        l.logf "done (#{ids.size.to_s})"
      end

      if fb_datas.size>0
        l.logs "Get leads with the same facebook... "
        ids += BlackStack::Leads::Data.where(
          :type => [BlackStack::Leads::Data::TYPE_FACEBOOK],
          :value => fb_datas.map { |d| d['value'] } 
        ).all.map{ |d| 
          d.id_lead
        }.uniq
        l.logf "done (#{ids.size.to_s})"
      end

      if ln_datas.size>0
        l.logs "Get leads with the same linkedin... "
        ids += BlackStack::Leads::Data.where(
          :type => [BlackStack::Leads::Data::TYPE_LINKEDIN],
          :value => ln_datas.map { |d| d['value'] } 
        ).all.map{ |d| 
          d.id_lead
        }.uniq
        l.logf "done (#{ids.size.to_s})"
      end
      
      # if there is no emails, no facebooks and no linkedins, then
      if email_datas.size == 0 && fb_datas.size == 0 && ln_datas.size == 0
        # if no leads have been found, and ...
        if ids.size==0
          # if the descriptor has a company name, then
          if !h['company'].nil?
            # build an array of existing lead ids, with the same first name, last name and company name.
            l.logs "Get leads with the same name and company... "
            ids = BlackStack::Leads::Lead.where(
              :name => h['name'],
              :stat_company_name => h['company']['name']
            ).all.map{ |l| l.id }.uniq
            l.logf "done (#{ids.size.to_s})"
          # or find leads with the same name
          else
            # build an array of existing lead ids, with the same first name, last name and company name.
            l.logs "Get leads with the same name and company... "
            ids = BlackStack::Leads::Lead.where(
              :name => h['name'],
              :stat_company_name => [nil, '']
            ).all.map{ |l| l.id }.uniq
            l.logf "done (#{ids.size.to_s})"
          end # if !h['company'].nil?
        end # if ids.size==0
      end

      # if h[:id_user] is present, then search only for leads with the same id_user.
      # otherwise, search only for public leads.
      if h.has_key?('id_user')
        l.logs "Filters account leads..."
        u = BlackStack::Leads::User.where(:id=>h['id_user']).first
        ids = BlackStack::Leads::Lead.where(:id_user => u.account.users.map { |u| u.id }, :id => ids).all.map{ |l| l.id } 
        l.logf "done (#{ids.size.to_s})"
      else
        l.logs "Filters public leads..."
        u = BlackStack::Leads::User.where(:id=>h['id_user']).first
        ids = BlackStack::Leads::Lead.where(:id_user => nil, :id => ids).all.map{ |l| l.id } 
        l.logf "done (#{ids.size.to_s})"
      end

      # remove deleted leads
      if ids.size>0
        # build an array of existing lead ids, with the same first name, last name and company name.
        l.logs "Filter non-deleted leads... "
        ids = BlackStack::Leads::Lead.where(
          :delete_time => nil,
          :id => ids
        ).all.map{ |l| l.id }.uniq
        l.logf "done (#{ids.size.to_s})"
      end

      # return
      ids.uniq
    end

    # Call self.ids_of_existing_leads to have array of IDs of leads
    # who match with the hash descriptor.
    # 
    # Return true if array of IDs has one or more elements
    def self.exists?(h,l=nil)
      self.ids_of_existing_leads(h).size > 0
    end

    # Call self.ids_of_existing_leads to have array of IDs of leads
    # who match with the hash descriptor.
    # 
    # if more than 1 lead is found, then raise an exception.
    # if 1 lead is found, then update that lead and return the lead.
    # if 0 ledas are found, then create a new lead and return it.
    #
    # Return the lead object (a new one, or an existing and updated one).
    # 
    # The object is not saved into the database. You have to do that after calling this method.
    # 
    def self.merge(h,l=nil)
      o = nil
      errors = BlackStack::Leads::Lead.validate_descriptor(h)
      raise "Errors found (#{errors.size.to_s}):\n#{errors.join("\n")}" if errors.size>0
      
      # create log object
      l = BlackStack::DummyLogger.new(nil) if l.nil?

      # build an array of exisiting lead ids, with one or more of the emails in the descriptor.
      ids = self.ids_of_existing_leads(h, l)

      # if there is more than one lead with the emails of this lead, raise an error.
      l.logs "Checking more than 1 lead... "
      if ids.size>1
        raise "More than one lead with the same keys (email, facebook, linkedin) found: #{h['datas'].map{|d| d['value']}.uniq.join(', ')}. Please clean up your leads." 
      else
        l.done
      end

      # assign the same id_user to the company
      h['company']['id_user'] = h['id_user'] if h.has_key?('id_user') && h['company'].is_a?(Hash)

      # if the lead already exists, then update it and return it.
      l.logs "Found a lead?... "
      if ids.size==1
        l.yes

        l.logs "Updating lead..."
        o = BlackStack::Leads::Lead.where(:id => ids.first).first
        o.update(h)
        l.done

        return o
      else
        l.no

        l.logs "Creating new lead... "
        o = BlackStack::Leads::Lead.new(h)
        l.done

        # if there is no lead with the same email, create a new one and return it.
        return o 
      end
    end # def self.merge(h)

    # receive an array of hash-descriptors
    # return an array of BlackStack::Leads::Lead objects.
    #
    def self.merge_many(h)
      raise ":leads must be an array. Received: #{h.to_s}" if !h['leads'].is_a?(Array)
      ret = []
      h['leads'].each { |l| ret << BlackStack::Leads::Lead.merge(l) }
      ret
    end

    # return the array of exports beloning to 'id_account'
    #
    # if `present == true`, then return only exports where the lead is beloning.
    # if `present == false`, then return only exports where the lead is not beloning.
    # if `present == nil`, then return all exports.
    # 
    # if the export is deleted, but the lead is still in it, show it
    # if the export is deleted, and the liead is not in it, do not show it.
    # 
    def export_lists_hash(id_account, present=nil)
      ret = []
      q = "
      SELECT e.id, e.filename, COUNT(el.id) AS belonging
      FROM \"user\" u
      JOIN fl_export e ON e.id_user = u.id
      LEFT JOIN fl_export_lead el ON ( el.id_export = e.id AND el.id_lead = '#{self.id}' AND el.delete_time IS NULL )
      WHERE u.id_account = '#{id_account.to_guid}'
      AND (e.delete_time IS NULL OR el.id_lead IS NOT NULL) -- if the export is deleted, but the lead is still in it, show it
      GROUP BY e.id
      ORDER BY e.filename
      "
      DB[q].all { |row|
        if (
          present.nil? || 
          (row[:belonging].to_i > 0 && present == true) ||
          (row[:belonging].to_i == 0 && present == false)
        )
          e = BlackStack::Leads::Export.where(:id=>row[:id]).first
          ret << e.to_hash
          DB.disconnect
          GC.start
        end # if row[:belonging].to_i > 0
      }
      ret
    end

    # return a hash descriptor for the data.
    def to_hash
      ret = { 
        'id' => id, 
        'name' => name, 
        'position' => position, 
      }
      ret['company'] = self.fl_company.nil? ? nil : self.fl_company.to_hash
      ret['industry'] = self.fl_industry.nil? ? nil : self.fl_industry.name
      ret['location'] = self.fl_location.nil? ? nil : self.fl_location.name
      ret['datas'] = self.fl_datas.map{|d| d.to_hash}
      ret['reminders'] = self.fl_reminders.sort_by { |d| d.expiration_time }.map{|d| d.to_hash}

      if BlackStack::Extensions.exists?(:'dfy-leads')
        ret['linkedin_picture_url'] = self.linkedin_picture_url
        ret['picture_url'] = self.picture_url
        ret['city'] = self.stat_city_name
        ret['state'] = self.stat_state_name
        ret['country'] = self.stat_country_name
        ret['area'] = self.stat_area_name
      end
      
      # release resources
      DB.disconnect
      GC.start
      # return
      ret
    end
  end
end
end