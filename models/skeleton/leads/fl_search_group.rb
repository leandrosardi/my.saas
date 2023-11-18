module BlackStack
module Leads
  class SearchGroup < Sequel::Model(:fl_search_group)
    many_to_one :fl_search, :class=>:'BlackStack::Leads::Search', :key=>:id_search

    def to_hash
      {
        'id'=>self.id,
        'value'=>self.value,
        'id_search'=>self.id_search
      }
    end

    def self.validate_descriptor(h)
      errors = []
      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)
      # hash validations
      if h.is_a?(Hash)
        # validation: key 'value' is mandatory
        errors << "Key 'value' is mandatory" if !h.has_key?('value')

        # validation: value 'value' must be a string
        if h.has_key?('value')
          errors << "Value 'value' must be a string" if !h['value'].is_a?(String)
        end

        # validation: if value is a string, then value must match with /https\:\/\/linkedin.com\/group\//
        if h.has_key?('value') && h['value'].is_a?(String)
          errors << "Value 'value' must match with /https\:\/\/linkedin.com\/group\//" if !h['value'].match(/https\:\/\/linkedin.com\/group\//)
        end
      end
      # return
      errors
    end # validate_descriptor

    # map a hash descriptor to the attributes of the object
    def update(h)
      self.value = h['value']
      self.id_search = h['id_search']
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::SearchPosition.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.update(h)
    end
  end # BlackStack::Leads::SearchGroup
end # Leads
end