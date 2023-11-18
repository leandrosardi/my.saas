module BlackStack
module Leads
  class Location < Sequel::Model(:fl_location)

    # validate the strucutre of the hash descritpor.
    # return an arrow of strings with the errors found. 
    def self.validate_descriptor(h)
      errors = []

      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)

      # validate: if :company is a hash, then it must have :name
      errors << "Descriptor :location must have :name (#{h.to_s})" if h.is_a?(Hash) && !h.has_key?('name')

# TODO: enable this validation just once we have a normalzed database of locations. - https://github.com/ConnectionSphere/leads/issues/33
=begin
      if !BlackStack::Leads::Location.where(:name=>h['name']).first
        errors << "Descriptor :location :name #{h['name']} not valid"
      end
=end

      # return the errors found.
      errors
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::Location.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.name = h['name']
    end

    # return a hash descriptor for the data.
    def to_hash
      { 'name' => name }
    end

  end
end
end
