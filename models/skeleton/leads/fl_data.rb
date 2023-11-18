module BlackStack
module Leads
  class Data < Sequel::Model(:fl_data)
    many_to_one :fl_lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead

    def after_create
      super
      self.fl_lead.update_stat_fields
    end

    def after_update
      super
      self.fl_lead.update_stat_fields
    end

    MATCH_FACEBOOK_USER_URL = /(https?:\/\/)?(www\.)?facebook\.com\/[-A-Za-z0-9\%\_\.\-]+/
    MATCH_LINKEDIN_USER_URL = /(https?:\/\/)?(www\.)?linkedin\.com\/in\/[-A-Za-z0-9\%\_\.\-]+/
    MATCH_SALES_NAVIGATOR_USER_URL = /(https?:\/\/)?(www\.)?linkedin\.com\/sales\/lead\//

    TYPE_CUSTOM = 0
    TYPE_COMPANY_NAME = 1
    TYPE_FIRST_NAME = 2
    TYPE_LAST_NAME = 3
    TYPE_LOCATION = 4
    TYPE_INDUSTRY = 5
    TYPE_PHONE = 10
    TYPE_EMAIL = 20
    TYPE_FACEBOOK = 80
    TYPE_TWITTER = 70
    TYPE_LINKEDIN = 90

    # reserved list of merge-tags.
    MERGETAGS = [
      'company-name',
      'first-name',
      'last-name',
      'location',
      'industry',
      'email-address',
      'phone-number',
      'linkedin-url',
      'twitter-url',
      'facebook-url'  
    ]

    def self.merge(h)
      o = BlackStack::Leads::Data.where(:id_lead=>h['id_lead'], :type=>h['type'], :value=>h['value']).first
      if o.nil?
        o = BlackStack::Leads::Data.new(h) 
      else
        o.update(h)
      end
      return o
    end

    # return an array of possibly valid types.
    def self.types
      [
        BlackStack::Leads::Data::TYPE_CUSTOM,
        BlackStack::Leads::Data::TYPE_COMPANY_NAME,
        BlackStack::Leads::Data::TYPE_FIRST_NAME,
        BlackStack::Leads::Data::TYPE_LAST_NAME,
        BlackStack::Leads::Data::TYPE_LOCATION,
        BlackStack::Leads::Data::TYPE_INDUSTRY,   
        BlackStack::Leads::Data::TYPE_PHONE,
        BlackStack::Leads::Data::TYPE_EMAIL,
        BlackStack::Leads::Data::TYPE_FACEBOOK,
        BlackStack::Leads::Data::TYPE_TWITTER,
        BlackStack::Leads::Data::TYPE_LINKEDIN,
      ]
    end

    # return a descriptive name for each one.
    # if `n` is an unknown value, then reutrn nil.
    def self.type_name(n)
      if n == BlackStack::Leads::Data::TYPE_CUSTOM
        'Custom'
      elsif n == BlackStack::Leads::Data::TYPE_COMPANY_NAME
        'Company Name'
      elsif n == BlackStack::Leads::Data::TYPE_FIRST_NAME
        'First Name'
      elsif n == BlackStack::Leads::Data::TYPE_LAST_NAME
        'Last Name'
      elsif n == BlackStack::Leads::Data::TYPE_LOCATION
        'Location'
      elsif n == BlackStack::Leads::Data::TYPE_INDUSTRY
        'Industry'
      elsif n == BlackStack::Leads::Data::TYPE_PHONE
        'Phone'
      elsif n == BlackStack::Leads::Data::TYPE_EMAIL
        'Email'
      elsif n == BlackStack::Leads::Data::TYPE_FACEBOOK
        'Facebook'
      elsif n == BlackStack::Leads::Data::TYPE_TWITTER
        'Twitter'
      elsif n == BlackStack::Leads::Data::TYPE_LINKEDIN
        'LinkedIn'
      else
        nil
      end
    end

    # return a descriptive name for each one.
    # if `n` is an unknown value, then reutrn nil.
    def self.type_merge_tag(n)
      if n == BlackStack::Leads::Data::TYPE_CUSTOM
        'Custom'
      elsif n == BlackStack::Leads::Data::TYPE_COMPANY_NAME
        'company-name'
      elsif n == BlackStack::Leads::Data::TYPE_FIRST_NAME
        'first-name'
      elsif n == BlackStack::Leads::Data::TYPE_LAST_NAME
        'last-name'
      elsif n == BlackStack::Leads::Data::TYPE_LOCATION
        'location'
      elsif n == BlackStack::Leads::Data::TYPE_INDUSTRY
        'industry'
      elsif n == BlackStack::Leads::Data::TYPE_PHONE
        'phone-number'
      elsif n == BlackStack::Leads::Data::TYPE_EMAIL
        'email-address'
      elsif n == BlackStack::Leads::Data::TYPE_FACEBOOK
        'facebook-url'
      elsif n == BlackStack::Leads::Data::TYPE_TWITTER
        'twitter-url'
      elsif n == BlackStack::Leads::Data::TYPE_LINKEDIN
        'linkedin-url'
      else
        nil
      end
    end

    # return a descripive name for the type of this object
    def type_name
      BlackStack::Leads::Data.type_name(self.type)
    end

    def self.exists?(id_lead, t, v)
      if t == BlackStack::Leads::Data::TYPE_LINKEDIN
        # remove query string from the url.
        # refernece: https://stackoverflow.com/questions/10410523/removing-a-part-of-a-url-with-ruby
        parsed = URI::parse(v)
        parsed.fragment = parsed.query = nil
        v = parsed.to_s
      end
      BlackStack::Leads::Data.where(:id_lead=>id_lead, :type=>t, :value=>v).count > 0
    end

    # validate the format of the value `v`, depending on the type `t`.
    def self.validate_value(t, v)
      if t == BlackStack::Leads::Data::TYPE_PHONE
        # we are not validating the format of the phone number by now, because phone numbers are not regular, so there is not a regular expression to validate them.
        return true
      elsif t == BlackStack::Leads::Data::TYPE_EMAIL
        # validate the format of the email.
        return v.to_s.email?
      elsif t == BlackStack::Leads::Data::TYPE_LINKEDIN
        # remove query string from the url.
        # refernece: https://stackoverflow.com/questions/10410523/removing-a-part-of-a-url-with-ruby
        parsed = URI::parse(v)
        parsed.fragment = parsed.query = nil
        url = parsed.to_s
        # validate the format of the linkedin url.
        return url =~ MATCH_LINKEDIN_USER_URL || url =~ MATCH_SALES_NAVIGATOR_USER_URL
      else
        true
      end
    end

    # validate the strucutre of the hash descritpor.
    # return an arrow of strings with the errors found. 
    def self.validate_descriptor(h)
      errors = []

      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)

      # validate: if h is a hash, then it must have :type
      errors << "Descriptor :data must have :type" if h.is_a?(Hash) && !h.has_key?('type')

      # validate: if h is a hash, and it has a :type key, then it must have a valid value.
      if h.is_a?(Hash) && h.has_key?('type')
        if !BlackStack::Leads::Data.types.include?(h['type'])
          errors << "Descriptor :data :type #{h['type']} not valid"
        end
      end

      # validate: if h is a hash, and it must have a :value
      errors << "Descriptor :data must have :value" if h.is_a?(Hash) && !h.has_key?('value')

      # validate: if h is a hash, and it has a :value, then the :value must be a string.
      if h.is_a?(Hash) && h.has_key?('value')
        if !h['value'].is_a?(String)
          errors << "Descriptor :data :value must be a string"
        end
      end

      # validate: if h is a hash, and it has a :type, and it has a :value, then the :value must valid
      if h.is_a?(Hash) && h.has_key?('type') && h.has_key?('value')
        if !BlackStack::Leads::Data.validate_value(h['type'], h['value'])
          errors << "Descriptor :data :value #{h['value']} not valid"
        end
      end
      
      # validate: if :type is custom, then it must have a :custom_field_name
      if h.is_a?(Hash) && h.has_key?('type') && h['type'] == BlackStack::Leads::Data::TYPE_CUSTOM
        errors << "Descriptor :data :type is custom, but :custom_field_name is missing" if !h.has_key?('custom_field_name')
      end

      # validate: if h is a hash, and it has a :verified, then :verified must be a boolean
      if h.is_a?(Hash) && h.has_key?('verified')
        if !h['verified'].is_a?(TrueClass) && !h['verified'].is_a?(FalseClass)
          errors << "Descriptor :data :verified must be a boolean"
        end
      end

      # return the errors found.
      errors
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::Data.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.create_time = now
      self.type = h['type']
      self.id_lead = h['id_lead']
      self.value = h['value']
      self.update(h)
    end

    # return a hash descriptor for the data.
    def to_hash
      {
        'id' => self.id,
        'type' => self.type,
        'value' => self.value,
        'delete_time' => self.delete_time,
        'deleted' => self.delete_time.nil? ? false : true,
        'verified' => self.verified,
        'custom_field_name' => self.custom_field_name,
        'mail_handler' => self.mail_handler,
        'source' => self.source
      }
    end

    # return nil if the data type is not an email
    # raise an exception if the data type is an email, but the email is not valid.
    # return an array with the companies who are hosting the mail of a domain, by running the linux command `host`
    def get_mail_handler
      # return nil if the data type is not an email
      return nil if self.type != BlackStack::Leads::Data::TYPE_EMAIL
      # raise an exception if the data type is an email, but the email is not valid.
      raise "Email #{self.value} is not valid" if !self.value.email?
      # return
      BlackStack::Netting.getMailHandler(self.value)
    end # get_mail_handler

    def update(h)
      self.custom_field_name = h['custom_field_name'] if !h['custom_field_name'].nil?
      self.verified = h['verified'] if !h['verified'].nil?
      self.mail_handler = h['mail_handler'] if !h['mail_handler'].nil?
      self.source = h['source'] if !h['source'].nil?
      if BlackStack::Extensions.exists?(:'dfy-leads')
        self.zb_status = h['zb_status'] if !h['zb_status'].nil?
        self.ev_status = h['ev_status'] if !h['ev_status'].nil?
        self.db_status = h['db_status'] if !h['db_status'].nil?
      end
    end

    # update the field `mail_handler` of the data.
    # return the new value of the field `mail_handler`
    def update_mail_handler
      data = self
      res = data.get_mail_handler
      res = res ? res.sort.join(',') : nil
      data.mail_handler = res
      data.save
      res
    end  

  end # class Data
end # BlackStack::Leads
end # BlackStack