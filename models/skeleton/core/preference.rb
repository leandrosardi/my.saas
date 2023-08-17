module BlackStack
    module MySaaS
        class Preference < Sequel::Model(:preference)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user

            TYPE_STRING = 1
            TYPE_INT = 2
            TYPE_FLOAT = 3
            TYPE_BOOL = 4

            # return the type of parameter x
            def self.type_of(x)
                # if x is a string
                if x.is_a?(String)
                    return BlackStack::MySaaS::Preference::TYPE_STRING
                elsif x.is_a?(Integer)
                    return BlackStack::MySaaS::Preference::TYPE_INT
                elsif x.is_a?(Float)
                    return BlackStack::MySaaS::Preference::TYPE_FLOAT
                elsif x.is_a?(TrueClass) || x.is_a?(FalseClass)
                    return BlackStack::MySaaS::Preference::TYPE_BOOL
                else
                    return nil
                end
            end

            # get a descriptive name for a type value
            def self.type_name(type)
                if type == BlackStack::MySaaS::Preference::TYPE_STRING
                    return "String"
                elsif type == BlackStack::MySaaS::Preference::TYPE_INT
                    return "Integer"
                elsif type == BlackStack::MySaaS::Preference::TYPE_FLOAT
                    return "Float"
                elsif type == BlackStack::MySaaS::Preference::TYPE_BOOL
                    return "Boolean"
                else
                    return "Unknown"
                end
            end

            def set_value(x)
                # if x is a string
                if x.is_a?(String)
                    self.value_string = x
                elsif x.is_a?(Integer)
                    self.value_int = x
                elsif x.is_a?(Float)
                    self.value_float = x
                elsif x.is_a?(TrueClass) || x.is_a?(FalseClass)
                    self.value_bool = x
                else
                    raise "Invalid `#{x.to_s}` value for preference #{self.name}. Expected String, Integer, Float, or Boolean."
                end
            end

            def get_value
                if self.type == BlackStack::MySaaS::Preference::TYPE_STRING
                    return self.value_string
                elsif self.type == BlackStack::MySaaS::Preference::TYPE_INT 
                    return self.value_int
                elsif self.type == BlackStack::MySaaS::Preference::TYPE_FLOAT
                    return self.value_float
                elsif self.type == BlackStack::MySaaS::Preference::TYPE_BOOL
                    return self.value_bool
                else
                    return nil
                end
            end

        end # class Preference
    end # module MySaaS
end # module BlackStack