module BlackStack
module Leads
  class SearchLocation < Sequel::Model(:fl_search_location)
    many_to_one :fl_search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
    #many_to_one :fl_location, :class=>:'BlackStack::Leads::Location', :key=>:id_location

    def to_hash
      {
        'id'=>self.id,
        'positive'=>self.positive,
        'id_search'=>self.id_search,
        'value'=>self.value
      } #.merge(self.fl_location.to_hash)
    end

    def self.validate_descriptor(h)
      errors = []
      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)
      # hash validations
      if h.is_a?(Hash)
        # validation: key 'value' is mandatory
        errors << "Key 'value' is mandatory" if !h.has_key?('value')

        # validation: key 'positive' is mandatory
        errors << "Key 'positive' is mandatory" if !h.has_key?('positive')

        # validation: value 'value' must be a string
        if h.has_key?('value')
          errors << "Value 'value' must be a string" if !h['value'].is_a?(String)
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
      self.value = h['value']
      self.positive = h['positive']
      self.id_search = h['id_search']
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::SearchLocation.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.update(h)
    end


  end # BlackStack::Leads::SearchLocation
end # Leads
end