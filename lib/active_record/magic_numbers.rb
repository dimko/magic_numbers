module ActiveRecord
    module MagicNumbers

        def self.included(base)
            base.extend(ClassMethods)
            base.send(:include, InstanceMethods)
        end

        module ClassMethods
            
            def enum_attribute(name, values, options={})
                magic_number_attribute(name, options.extend({
                    :values => values,
                    :type => :enum
                }))
            end

            def bitfield_attribute(name, values, options={})
                magic_number_attribute(name, options.extend({
                    :values => values,
                    :type => :bitfield
                }))
            end

            def magic_number_values(name)
                magic_number_options(name)[:values]
            end

            def magic_number_for(name, value)
                options = self.class.magic_number_options(name)
                values = options[:values]

                value = value.is_a?(Array) ? value.map(&:to_s) : value.to_s

                if options[:type] == :bitfield
                    (values & value).map { |v| 2**values.index(v) }.sum
                else
                    values[value]
                end
            end

            protected

            def magic_number_options(read)
                read_inheritable_attribute(:magic_number_attributes) || {}
            end

            def magic_number_attribute(name, options)
                options.assert_valid_keys(:values, :type, :default) 
                options[:values].map!(&:to_s) 

                magic_number_attributes = read_inheritable_attribute(:magic_number_attributes) || {}

                magic_number_attributes[name] = options
                write_inheritable_attribute(:magic_number_attributes, magic_number_attributes)

                class_eval <<-EOE
                    def #{name}; magic_numbers_read(:#{name}); end
                    def #{name}=(new_value); magic_numbers_write(:#{name}, new_value); end
                    def self.#{name}_values; magic_numbers_values(:#{name}); end
                EOE
            end
        end

        module InstanceMethods

            def magic_number_read(name)
                options = self.class.magic_number_options(name)
                values = options[:values]
                mask_value = self["#{ name }_mask"]

                if options[:type] == :bitfield
                    result = values.reject { |r| ((mask_value || 0) & 2**values.index(r)).zero? }
                    (result.empty? && options[:default]) ? options[:default] : result
                else
                    values[mask_value] || options[:default]
                end
            end

            def magic_numbers_write(name, new_value)
                self["#{ name }_mask"] = self.class.magic_number_for(name, new_value)
            end

        end
    end
end
