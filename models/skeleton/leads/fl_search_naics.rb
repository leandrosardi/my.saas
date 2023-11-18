module BlackStack
module Leads
  class SearchNaics < Sequel::Model(:fl_search_naics)
    many_to_one :fl_search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
    many_to_one :fl_naics, :class=>:'BlackStack::Leads::Naics', :key=>:id_naics

    def to_hash
      {
        'id'=>self.id,
        'positive'=>self.positive,
        'id_search'=>self.id_search
      }.merge(self.fl_naics.to_hash)
    end

    def self.validate_descriptor(h)
      errors = []
      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)
      # hash validations
      if h.is_a?(Hash)
        # validation: key 'code' is mandatory
        errors << "Key 'code' is mandatory" if !h.has_key?('code')

        # validation: key 'positive' is mandatory
        errors << "Key 'positive' is mandatory" if !h.has_key?('positive')

        # validation: value 'code' must exists in the table
        if h.has_key?('code') && h['code'].to_s.length > 0
          industry = FlNaics.where(:code=>h['code']).first
          errors << "Value 'code' must exists in the table fl_naics" if industry.nil?
        end

        # validation: value 'positive' must be a boolean
        if h.has_key?('positive')
          errors << "Value 'positive' must be a boolean" if !h['positive'].is_a?(TrueClass) && !h['positive'].is_a?(FalseClass)
        end
      end
      # return
      errors
    end # validate_descriptor

    # map a hash descriptor to the attributes of the object
    def update(h)
      self.id_naics = h['code'].to_s.length > 0 ? BlackStack::Leads::Naics.where(:code=>h['code']).first.id : nil
      self.positive = h['positive']
      self.id_search = h['id_search']
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::SearchNaics.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.update(h)
    end
  end # BlackStack::Leads::SearchNaics
end # Leads
end