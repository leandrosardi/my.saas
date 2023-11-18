module BlackStack
module Leads
  class Company < Sequel::Model(:fl_company)
    many_to_one :user, :class=>:'BlackStack::Leads::User', :key=>:id_user
    one_to_many :fl_leads, :class=>:'BlackStack::Leads::Lead', :key=>:id_company
    many_to_one :fl_revenue, :class=>:'BlackStack::Leads::Revenue', :key=>:id_revenue
    many_to_one :fl_headcount, :class=>:'BlackStack::Leads::Headcount', :key=>:id_headcount

    def after_create
      super
      #self.fl_leads.each { |lead| lead.update_stat_fields } 
    end

    def after_update
      super
      #self.fl_leads.each { |lead| lead.update_stat_fields } 
    end

    # validate the strucutre of the hash descritpor.
    # return an arrow of strings with the errors found. 
    def self.validate_descriptor(h)
      errors = []

      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)

      # validate: if it has :url, then :url must be a valid URL
      if h.is_a?(Hash) && h.has_key?('url') && !h['url'].nil?
        begin
          URI.parse(h['url'])
        rescue URI::InvalidURIError
          errors << "Descriptor :company :url must be a valid URL (#{h['url']})"
        end
      end

      if BlackStack::Extensions.exists?(:'dfy-leads')
        if h.is_a?(Hash)
          # Validate: if :linkedin_url exists, it must be a string
          if h.has_key?('linkedin_url') && h['linkedin_url'] && !h['linkedin_url'].is_a?(String)
            errors << ":linkedin_url must be a string. Received: #{h['linkedin_url'].to_s}"
          end
        end # if h.is_a?(Hash)
      end

      # validate: if :company is a hash, then it must have :name
      errors << "Descriptor :company must have :name" if h.is_a?(Hash) && !h.has_key?('name')

      # return the errors found.
      errors
    end

    # normalize the url in the hash descriptor, getting the domain with its subdomains, except `www.`, and finally downcasing it.
    # this method should not be called by the user.
    def self.normalize_url(url)
      return nil if url.nil?
      #return nil if !url.to_s.url? # glitch: urls like 'http://foo.ca' are not passing this validation
      # get the domain with its subdomains, except www.
      url.to_s.gsub(/^https?:\/\//, '').gsub(/www\./, '').gsub(/\/.*$/, '').downcase
    end

    # normalize the url in the hash descriptor.
    # if exsits a company with the same normalized url, then return it. otherwise, create a new company.
    def self.merge(h)
      company = nil
      # if h['id_user'] exists, get the account
      u = BlackStack::MySaaS::User.where(:id=>h['id_user']).first if h.has_key?('id_user')
      a = u.nil? ? nil : u.account
      # validate h is a hash
      raise "Company descriptor must be a hash" if !h.is_a?(Hash)
      # initialize :url
      h['url'] = nil if !h.has_key?('url')
      # normaize the url in order to find it in the database
      h['url'] = BlackStack::Leads::Company.normalize_url(h['url']) if h.has_key?('url')
      # find the company with the same id
      company = BlackStack::Leads::Lead.where(:id=>h['id']).first if h.has_key?('id')
      # if the company is still nil, find the company from id_user and url
      if company.nil? && h.has_key?('url')
        if !a.nil?
          company = BlackStack::Leads::Company.where(:id_user=>a.users.map { |v| v.id  }, :url=>h['url']).first
        else
          company = BlackStack::Leads::Company.where(:id_user=>nil, :url=>h['url']).first
        end
      end
      # if the company is still nil, find the company from id_user and name
      if company.nil? && h.has_key?('name')
        if !a.nil?
          company = BlackStack::Leads::Company.where(:id_user=>a.users.map { |v| v.id  }, :name=>h['name'], :url=>nil).first
        else
          company = BlackStack::Leads::Company.where(:id_user=>nil, :name=>h['name'], :url=>nil).first
        end
      end
      # if the company is still nil, create the company
      if company.nil?
        company = BlackStack::Leads::Company.new
        company.id = guid
        #company.create_time = now
      end
      # map new attributes to the company
      company.parse(h)
      # return the company
      company
    end

    def parse(h)
      #self.id = h['id']
      self.name = h['name']
      self.url = BlackStack::Leads::Company.normalize_url(h['url'])
      self.id_user = h['id_user'] if h.has_key?('id_user')
      if BlackStack::Extensions.exists?(:'dfy-leads')
        self.linkedin_url = h['linkedin_url']
      end
    end # def parse
=begin
    # constructor
    def initialize(h=nil)
      super()
      if h.is_a?(Hash)
        errors = BlackStack::Leads::Company.validate_descriptor(h)
        raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
        # map the hash to the attributes of the model.
        self.parse(h)
      end
    end
=end
    # return a hash descriptor for the data.
    def to_hash
      h = { 'id' => id, 'id_user' => id_user, 'name' => name, 'url' => url }
      if BlackStack::Extensions.exists?(:'dfy-leads')
        h['linkedin_url'] = linkedin_url
      end
      h
    end
    
  end # class Company
end # module Leads
end # 
