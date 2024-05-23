module BlackStack
    module CRUD
        @@cruds = {}

        def self.cruds
            @@cruds
        end

        def self.add_crud(key, h)
            err = []
            # validate
            err << "key must be a symbol" if !key.is_a?(Symbol)
            # validate: h must be a hash
            err << "h must be a hash" if !h.is_a?(Hash)
            # class must exist must be the name of an existing class
            err << "class must exist" if h[:class].nil?
            err << "class must be a string" if !h[:class].nil? && !h[:class].is_a?(String)
            err << "class must be a valid class" if !h[:class].nil? && !Object.const_defined?(h[:class])

            @@cruds[key] = h
        end

        def self.set(h)
            # TODO: Validate!
            @@cruds = h
        end

        def self.get(key)
            @@cruds[key]
        end

        def self.draw_table(crud, field)
            # TODO: code me!
        end

        def self.draw_crud_fields(crud, field)
            # TODO: code me!
        end

    end # module CRUD
end # module BlackStack