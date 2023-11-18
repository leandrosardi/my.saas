module BlackStack
module Leads
  class Sic < Sequel::Model(:fl_sic)

    # validate the strucutre of the hash descritpor.
    # return an arrow of strings with the errors found. 
    def self.validate_descriptor(h)
      errors = []

      # validate: h must be a hash
      errors << "Descriptor must be a hash" if !h.is_a?(Hash)

      # validate: if :company is a hash, then it must have :name
      errors << "Descriptor must have :name (#{h.to_s})" if h.is_a?(Hash) && !h.has_key?('name')

      # valdidate: if :company is a hash, then it must have :code
      errors << "Descriptor must have :code (#{h.to_s})" if h.is_a?(Hash) && !h.has_key?('code')

      if h['code'].is_a?(String)
        if !BlackStack::Leads::Sic.where(:name=>h['code']).first
          errors << "Descriptor :code #{h['code']} not valid"
        end
      end

      # return the errors found.
      errors
    end

    # constructor
    def initialize(h)
      super()
      errors = BlackStack::Leads::Sic.validate_descriptor(h)
      raise "Errors found:\n#{errors.join("\n")}" if errors.size>0
      # map the hash to the attributes of the model.
      self.id = guid
      self.code = h['code']
      self.name = h['name']
    end

    # return a hash descriptor for the data.
    def to_hash
      { 'code' => code, 'name' => name }
    end

  end # def FlSic
end # module Leads
end # module BlackStack