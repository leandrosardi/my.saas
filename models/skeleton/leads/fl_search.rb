module BlackStack
module Leads
  class Search < Sequel::Model(:fl_search)
    include BlackStack::TableHelper

    many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
    one_to_many :positions, :class=>'BlackStack::Leads::SearchPosition', :key=>:id_search
    one_to_many :locations, :class=>'BlackStack::Leads::SearchLocation', :key=>:id_search
    one_to_many :industries, :class=>'BlackStack::Leads::SearchIndustry', :key=>:id_search
    one_to_many :revenues, :class=>'BlackStack::Leads::SearchRevenue', :key=>:id_search
    one_to_many :headcounts, :class=>'BlackStack::Leads::SearchHeadcount', :key=>:id_search
    one_to_many :naicss, :class=>'BlackStack::Leads::SearchNaics', :key=>:id_search
    one_to_many :sics, :class=>'BlackStack::Leads::SearchSic', :key=>:id_search

    PULL_REQUEST_PENDING = 0
    PULL_REQUEST_IN_PROGRESS = 1
    PULL_REQUEST_DONE = 2

    def self.validate_descriptor(h)
      errors = []
      
      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)

      if h.is_a?(Hash)
        # validate: :id_user is mandatory
        errors << "id_user is mandatory" if h['id_user'].to_s.size == 0

        # validate: if :name is present, it must be a valid string
        errors << "lead_name must be a valid string" if h['lead_name'].to_s.size > 0 && !h['lead_name'].is_a?(String)

        # validate: if :id_order is present, it must be a valid guid
        errors << "id_order must be a valid guid" if h['id_order'].to_s.size > 0 && !h['id_order'].guid?

        # validate: if :id_export is present, it must be a valid guid
        errors << "id_export must be a valid guid" if h['id_export'].to_s.size > 0 && !h['id_export'].guid?

        # validate: if :verified_only is present, it must be a valid boolean
        errors << "verified_only must be a valid boolean" if !h['verified_only'].nil? && !h['verified_only'].is_a?(TrueClass) && !h['verified_only'].is_a?(FalseClass)

        # validate: if :min_trust_rate is present, it must be a valid integer
        errors << "min_trust_rate must be a valid integer" if !h['min_trust_rate'].nil? && !h['min_trust_rate'].is_a?(Integer)

        # validate: if :private_only is present, it must be a valid boolean
        errors << "private_only must be a valid boolean" if !h['private_only'].nil? && !h['private_only'].is_a?(TrueClass) && !h['private_only'].is_a?(FalseClass)

        # validate: :name is mandatory
        errors << "name is mandatory" if h['name'].to_s.size == 0

        # validate: the value of :id_user must be a valid guid
        errors << "id_user must be a valid guid" if h['id_user'].to_s.size > 0 && !h['id_user'].guid?

        # validate: the value of :name must be a valid string
        errors << "name must be a valid string" if !h['name'].is_a?(String)

        # validate: the value of :description must be nil, or must be a valid string not empty
        errors << "description must be nil or a valid string" if (
          (h['description'].is_a?(String) && h['description'].to_s.size == 0) ||
          (!h['description'].nil? && !h['description'].is_a?(String))
        )

        # validate: the value of :saved must be a valid boolean
        errors << "saved must be a valid boolean" if !h['saved'].is_a?(TrueClass) && !h['saved'].is_a?(FalseClass)
        
        # validate: the value of :no_of_results must be a valid integer or nil
        errors << "no_of_results must be a valid integer or nil" if !h['no_of_results'].is_a?(Integer) && !h['no_of_results'].nil?

        # validate: the value of :no_of_companies must be a valid integer or nil or nil
        errors << "no_of_companies must be a valid integer or nil" if !h['no_of_companies'].is_a?(Integer) && !h['no_of_companies'].nil?

        # validation: 'positions' must be nil or an array
        errors << "positions must be nil or an array" if !h['positions'].nil? && !h['positions'].is_a?(Array)

        # validation: 'locations' must be nil or an array
        errors << "locations must be nil or an array" if !h['locations'].nil? && !h['locations'].is_a?(Array)

        # validation: 'industries' must be nil or an array
        errors << "industries must be nil or an array" if !h['industries'].nil? && !h['industries'].is_a?(Array)
        
        # validation: if 'positions' is an array, each element must be valid
        if !h['positions'].nil? && h['positions'].is_a?(Array)
          h['positions'].each do |p|
            errors += BlackStack::Leads::SearchPosition.validate_descriptor(p)
          end
        end

        # validation: if 'locations' is an array, each element must be valid
        if !h['locations'].nil? && h['locations'].is_a?(Array)
          h['locations'].each do |l|
            errors += BlackStack::Leads::SearchLocation.validate_descriptor(l)
          end
        end
        
        # validation: if 'industries' is an array, each element must be valid
        if !h['industries'].nil? && h['industries'].is_a?(Array)
          h['industries'].each do |i|
            errors += BlackStack::Leads::SearchIndustry.validate_descriptor(i)
          end
        end


        # validation: if 'naicss' is an array, each element must be valid
        if !h['naicss'].nil? && h['naics'].is_a?(Array)
          h['naicss'].each do |n|
            errors += BlackStack::Leads::SearchNaics.validate_descriptor(n)
          end
        end

        # validation: if 'sics' is an array, each element must be valid
        if !h['sics'].nil? && h['sics'].is_a?(Array)
          h['sics'].each do |s|
            errors += BlackStack::Leads::SearchSic.validate_descriptor(s)
          end
        end

        # validation: if 'revenues' is an array, each element must be valid
        if !h['revenues'].nil? && h['revenues'].is_a?(Array)
          h['revenues'].each do |r|
            errors += BlackStack::Leads::SearchRevenue.validate_descriptor(r)
          end
        end

        # validation: if 'headcounts' is an array, each element must be valid
        if !h['headcounts'].nil? && h['headcounts'].is_a?(Array)
          h['headcounts'].each do |h|
            errors += BlackStack::Leads::SearchHeadcount.validate_descriptor(h)
          end
        end

        # validation: if 'company_only' exists, it must be a boolean
        if h.has_key?('company_only')
          errors << "company_only must be a valid boolean" if !h['company_only'].is_a?(TrueClass) && !h['company_only'].is_a?(FalseClass)
        end

        # validation: if 'phone_only' exists, it must be a boolean
        if h.has_key?('phone_only')
          errors << "phone_only must be a valid boolean" if !h['phone_only'].is_a?(TrueClass) && !h['phone_only'].is_a?(FalseClass)
        end

        # validation: if 'email_only' exists, it must be a boolean
        if h.has_key?('email_only')
          errors << "email_only must be a valid boolean" if !h['email_only'].is_a?(TrueClass) && !h['email_only'].is_a?(FalseClass)
        end
      end # if h.is_a?(Hash)

      errors
    end

    # map a hash descriptor to the attributes of the object
    def update(h)
      self.name = h['name']
      self.description = h['description']
      self.id_user = h['id_user']
      self.saved = h['saved']
      self.no_of_results = h['no_of_results']
      self.no_of_companies = h['no_of_companies']
      
      self.lead_name = h['lead_name'] if h.has_key?('lead_name')

=begin # a saved search shouldn't be updated never
      # remove all positions
      self.positions.each do |p|
        p.delete
      end
      # remove all locations
      self.locations.each do |l|
        l.delete
      end
      # remove all industries
      self.industries.each do |i|
        i.delete
      end
=end
      # map id_export if it exists
      self.id_export = h['id_export'] if h.has_key?('id_export')
      # map verified_only if it exists
      self.verified_only = h['verified_only'] if h.has_key?('verified_only')
      # map min_trust_rate if it exists
      self.min_trust_rate = h['min_trust_rate'] if h.has_key?('min_trust_rate')
      # map private_only if it exists
      self.private_only = h['private_only'] if h.has_key?('private_only')
      # map the array of positions
      if !h['positions'].nil? && h['positions'].is_a?(Array)
        h['positions'].each { |p| self.positions << BlackStack::Leads::SearchPosition.new(p) }
      end
      # map the array of locations
      if !h['locations'].nil? && h['locations'].is_a?(Array)
        h['locations'].each { |l| self.locations << BlackStack::Leads::SearchLocation.new(l) }
      end
      # map the array of industries
      if !h['industries'].nil? && h['industries'].is_a?(Array)
        h['industries'].each { |i| self.industries << BlackStack::Leads::SearchIndustry.new(i) }
      end
      # map the array of naicss
      if !h['naicss'].nil? && h['naicss'].is_a?(Array)
        h['naicss'].each { |n| self.naicss << BlackStack::Leads::SearchNaics.new(n) }
      end
      # map the array of sics
      if !h['sics'].nil? && h['sics'].is_a?(Array)
        h['sics'].each { |s| self.sics << BlackStack::Leads::SearchSic.new(s) }
      end
      # map the array of revenues
      if !h['revenues'].nil? && h['revenues'].is_a?(Array)
        h['revenues'].each { |r| self.revenues << BlackStack::Leads::SearchRevenue.new(r) }
      end
      # map the array of headcounts
      if !h['headcounts'].nil? && h['headcounts'].is_a?(Array)
        h['headcounts'].each { |h| self.headcounts << BlackStack::Leads::SearchHeadcount.new(h) }
      end
      # map the company_only attribute
      if h.has_key?('company_only')
        self.company_only = h['company_only']
      else
        self.company_only = false
      end
      # map the phone_only attribute
      if h.has_key?('phone_only')
        self.phone_only = h['phone_only']
      else
        self.phone_only = false
      end
      # map the email_only attribute
      if h.has_key?('email_only')
        self.email_only = h['email_only']
      else
        self.email_only = false
      end
    end

    def to_hash
      h = {}

      h['id'] = self.id
      h['name'] = self.name
      h['description'] = self.description
      h['id_user'] = self.id_user
      h['saved'] = self.saved
      h['no_of_results'] = self.no_of_results
      h['no_of_companies'] = self.no_of_companies

      h['lead_name'] = self.lead_name

      h['id_export'] = self.id_export
      h['verified_only'] = self.verified_only
      h['min_trust_rate'] = self.min_trust_rate
      h['private_only'] = self.private_only

      h['positions'] = []
      self.positions.each do |p|
        h['positions'] << p.to_hash
      end

      h['locations'] = []
      self.locations.each do |l|
        h['locations'] << l.to_hash
      end

      h['industries'] = []
      self.industries.each do |i|
        h['industries'] << i.to_hash
      end

      h['naicss'] = []
      self.naicss.each do |n|
        h['naicss'] << n.to_hash
      end

      h['sics'] = []
      self.sics.each do |s|
        h['sics'] << s.to_hash
      end

      h['revenues'] = []
      self.revenues.each do |r|
        h['revenues'] << r.to_hash
      end

      h['headcounts'] = []
      self.headcounts.each do |r|
        h['headcounts'] << r.to_hash
      end

      h['company_only'] = self.company_only
      h['phone_only'] = self.phone_only
      h['email_only'] = self.email_only

      h
    end # def to_hash

    # save this object, and all the objects of the associations
    def save
      super
      self.positions.each { |p| 
        p.id_search=self.id
        p.save 
      }
      self.locations.each { |l| 
        l.id_search=self.id
        l.save
      }
      self.industries.each { |i| 
        i.id_search=self.id
        i.save
      }
      self.naicss.each { |n|
        n.id_search=self.id
        n.save
      }
      self.sics.each { |s|
        s.id_search=self.id
        s.save
      }
      self.revenues.each { |r|
        r.id_search=self.id
        r.save
      }
      self.headcounts.each { |h|
        h.id_search=self.id
        h.save
      }
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::Search.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.create_time = now
      self.update(h)
      self
    end

    # This method works with the TableHelper module.
    # Return the FROM-WHERE part of the SQL query to retrieve the results of the table, with not pagination nor sorting, nor listed columns.
    # This method is used to build custom queries on other methods.
    #
    # if id_account is not nil, the query will return the number of export lists of such an account where the lead is included.
    # if id_account is nil, the query will return the number of all export lists where the lead is included.
    # 
    def core(h={})
      id_account = h['id_account']
      exports = id_account.nil? ? [] : BlackStack::Leads::Account.where(:id=>id_account).first.exports

      q0 = "
        FROM fl_lead l
      "

      if self.id_export
        q0 += "
          JOIN fl_export_lead e ON (l.id=e.id_lead AND e.id_export='#{self.id_export.to_guid}')
        "
      end

      # each user can see its own leads, or public leads (id_user=nil)
      q0 += "
        WHERE (
          l.id_user IS NULL
          OR
          l.id_user IN ('#{self.user.account.users.map { |u| u.id }.join("','")}')
        )
        AND l.delete_time IS NULL
      "

      if self.lead_name
        q0 += "
          AND l.name LIKE '%#{self.lead_name.to_s.to_sql}%'
        "
      end

      if self.verified_only
        q0 += "
          AND COALESCE(l.stat_verified, false) = true
        "
      end

      if self.min_trust_rate
        q0 += "
          AND COALESCE(l.stat_trust_rate, 0) >= #{self.min_trust_rate.to_i}
        "
      end

      if self.private_only
        q0 += "
          AND l.id_user IS NOT NULL
          AND l.id_user IN ('#{self.user.account.users.map { |u| u.id }.join("','")}')
        "
      end

      # filter by positive job positions
      a = self.positions.select { |p| p.positive }
      if a.size > 0
        q0 += " AND ( "
        a.each_with_index do |p,i|
          q0 += " UPPER(l.position) LIKE '%#{p.value.to_s.upcase.to_sql}%' "
          q0 += " OR " if i<a.size-1
        end
        q0 += " ) "
      end # if a.size > 0

      # filter by negative job positions
      a = self.positions.select { |p| !p.positive }
      if a.size > 0
        a.each_with_index do |p,i|
          q0 += " AND NOT UPPER(l.position) LIKE '%#{p.value.to_s.upcase.to_sql}%' "
        end
      end

      # filter by positive locations
      a = self.locations.select { |l| l.positive }
      if a.size > 0
        q0 += " AND ( "
        a.each_with_index do |l,i|
          q0 += " UPPER(l.stat_location_name) LIKE '%#{l.value.to_s.upcase.to_sql}%' "
          q0 += " OR " if i<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative locations
      a = self.locations.select { |l| !l.positive }
      if a.size > 0
        a.each_with_index do |l,i|
          q0 += " AND NOT UPPER(l.stat_location_name) LIKE '%#{l.value.to_s.upcase.to_sql}%' "
        end
      end

      # filter by positive industries
      a = self.industries.select { |i| i.positive }
      if a.size > 0
        q0 += " AND ("
        a.each_with_index do |i,k|
          q0 += " UPPER(l.stat_industry_name) LIKE '%#{i.fl_industry.name.to_s.upcase.to_sql}%' "
          q0 += " OR " if k<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative industries
      a = self.industries.select { |i| !i.positive }
      if a.size > 0
        a.each_with_index do |i,k|
          q0 += " AND NOT UPPER(l.stat_industry_name) LIKE '%#{i.fl_industry.name.to_s.upcase.to_sql}%' "
        end
      end
=begin
      # filter by positive naicss
      a = self.naicss.select { |n| n.positive }
      if a.size > 0
        q0 += " AND ("
        a.each_with_index do |n,k|
          q0 += " l.stat_naics_codes LIKE '%#{n.fl_naics.code.to_s.to_sql}%' "
          q0 += " OR " if k<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative naicss
      a = self.naicss.select { |n| !n.positive }
      if a.size > 0
        a.each_with_index do |n,k|
          q0 += " AND NOT l.stat_naics_codes LIKE '%#{n.fl_naics.code.to_s.to_sql}%' "
        end
      end

      # filter by positive sics
      a = self.sics.select { |s| s.positive }
      if a.size > 0
        q0 += " AND ("
        a.each_with_index do |s,k|
          q0 += " l.stat_sic_codes LIKE '%#{s.fl_sic.code.to_s.to_sql}%' "
          q0 += " OR " if k<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative sics
      a = self.sics.select { |s| !s.positive }
      if a.size > 0
        a.each_with_index do |s,k|
          q0 += " AND NOT l.stat_sic_codes LIKE '%#{s.fl_sic.code.to_s.to_sql}%' "
        end
      end

      # filter by positive revenues
      a = self.revenues.select { |r| r.positive }
      if a.size > 0
        q0 += " AND ("
        a.each_with_index do |r,k|
          q0 += " l.stat_revenue LIKE '%#{r.fl_revenue.name.to_s.to_sql}%' "
          q0 += " OR " if k<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative revenues
      a = self.revenues.select { |r| !r.positive }
      if a.size > 0
        a.each_with_index do |r,k|
          q0 += " AND NOT l.stat_revenue LIKE '%#{r.fl_revenue.name.to_s.to_sql}%' "
        end
      end

      # filter by positive headcounts
      a = self.headcounts.select { |h| h.positive }
      if a.size > 0
        q0 += " AND ("
        a.each_with_index do |h,k|
          q0 += " l.stat_headcount LIKE '%#{h.fl_headcount.name.to_s.to_sql}%' "
          q0 += " OR " if k<a.size-1
        end
        q0 += " ) "
      end

      # filter by negative headcounts
      a = self.headcounts.select { |h| !h.positive }
      if a.size > 0
        a.each_with_index do |h,k|
          q0 += " AND NOT l.stat_headcount LIKE '%#{h.fl_headcount.name.to_s.to_sql}%' "
        end
      end
=end
      # filter by company_only
      if self.company_only
        q0 += " AND l.id_company IS NOT NULL "
      end

      # filter by phone_only
      if self.phone_only
        q0 += " AND l.stat_has_phone = true "
      end

      # filter by phone_only
      if self.email_only
        q0 += " AND l.stat_has_email = true "
      end

      # return
      q0
    end

    # This method works with the TableHelper module.
    # return an array of hashes with the columns of the table
    def columns(h={})
      id_account = h['id_account'].nil? ? nil : h['id_account']

      [
        { 'query_field' => 'l.id' }, 
        { 'query_field' => 'l.id_user' }, 
        { 'query_field' => 'l.linkedin_picture_url' }, 
        { 'query_field' => 'l.picture_url' }, 
        {
          'query_field' => 'l.name',
          # braninstorm a general-pourpose screen descriptor
=begin
          'visible' => true,
          'label' => 'Name',
          'sortable' => true,
          'searchable' => {
            'search_type' => 'text' # text, integer, float, boolean, date, date-range, datetime, select, multiselect
            'autocomplete_values' => {
              'values' => [],
              'strict' => false, # true or false - don't allow to filters outside the list of possible values
            },
          }
=end        
        },
        { 'query_field' => 'l.position' }, 
        { 'query_field' => 'l.stat_company_name' }, 
        { 'query_field' => 'l.stat_industry_name' },
        { 'query_field' => 'l.stat_location_name' },
        { 'query_field' => 'l.stat_has_email' },
        { 'query_field' => 'l.stat_has_phone' }, 
        { 'query_field' => 'l.stat_verified' },
        { 'query_field' => 'l.stat_trust_rate' },
        { 'query_field' => "
          (
            SELECT d.value
            FROM fl_data d
            WHERE d.id_lead=l.id
            AND d.type = #{BlackStack::Leads::Data::TYPE_LINKEDIN.to_s}
            AND d.delete_time IS NULL
            LIMIT 1
          ) AS linkedin_url
        "},
        { 'query_field' => "
          (
            SELECT d.value
            FROM fl_data d
            WHERE d.id_lead=l.id
            AND d.type = #{BlackStack::Leads::Data::TYPE_FACEBOOK.to_s}
            AND d.delete_time IS NULL
            LIMIT 1
          ) AS facebook_url
        "},
        { 'query_field' => "
          (
            CASE 
            WHEN (
              SELECT COUNT(*) AS n 
              FROM fl_export_lead el
              JOIN fl_export e ON e.id=el.id_export
              JOIN \"user\" u ON (u.id=e.id_user #{id_account.nil? ? '' : "AND u.id_account='#{id_account}'"})
              WHERE el.id_lead=l.id
            ) > 0 THEN true
            ELSE false
            END
          ) AS exported
        "},
      ]
    end

    # reurn an array of lead objects who match with the filters of the search.
    def leads(h)
      self.rows(h).map { |row| 
        BlackStack::Leads::Lead.where(:id=>row[:id]).first 
        # release resources
        GC.start
        DB.disconnect
      }
    end

    # total number of unique leads with leads mathcing with this search
    def count_leads
      DB["SELECT COUNT(DISTINCT id) AS n #{self.core}"].first[:n]
    end

    # total number of unique companies with leads mathcing with this search
    def count_companies
      DB["SELECT COUNT(DISTINCT id_company) AS n #{self.core}"].first[:n]
    end
  end # class Search
end # module Leads
end # module BlackStack