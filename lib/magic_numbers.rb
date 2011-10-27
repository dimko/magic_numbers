module MagicNumbers
  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods

      def enum_attribute(name, values, options = {})
        magic_number_attribute(name, options.merge({
          :values => values,
          :type => :enum
        }))
      end

      def bitfield_attribute(name, values, options = {})
        magic_number_attribute(name, options.merge({
          :values => values,
          :type => :bitfield
        }))
      end

      def magic_number_values(name)
        magic_number_options(name)[:values]
      end

      def magic_number_for(name, value)
        options = self.magic_number_options(name)
        values, offset = options[:values], options[:offset] || 0

        value = value.is_a?(Array) ? value.map(&:to_s) : value.to_s

        if options[:type] == :bitfield
          (values & value).map { |v| 2**values.index(v) }.sum
        else
          (values.index(value).try(:+, offset)) || options[:default]
        end
      end

      def magic_number_options(name)
        read_inheritable_attribute(:magic_number_attributes)[name]
      end

      protected

        def magic_number_attribute(name, options)
          options.assert_valid_keys(:values, :type, :default, :column, :offset)
          options[:values].map!(&:to_s)

          options[:column] = name unless options[:column].present?

          magic_number_attributes = read_inheritable_attribute(:magic_number_attributes) || {}

          magic_number_attributes[name] = options
          write_inheritable_attribute(:magic_number_attributes, magic_number_attributes)

          class_eval <<-EOE
            def #{name}; magic_number_read(:#{name}); end
            def #{name}=(new_value); magic_number_write(:#{name}, new_value); end
            def self.#{name}_values; magic_number_values(:#{name}); end
          EOE
        end

    end

    module InstanceMethods

      def magic_number_read(name)
        options = self.class.magic_number_options(name)
        values, offset = options[:values], options[:offset] || 0
        mask_value = self[options[:column]]

        if options[:type] == :bitfield
          result = values.reject { |r| ((mask_value || 0) & 2**values.index(r)).zero? }
        else
          (mask_value && values[mask_value - offset].try(:to_sym))
        end
      end

      def magic_number_write(name, new_value)
        options = self.class.magic_number_options(name)

        self[options[:column]] = self.class.magic_number_for(name, new_value)
      end

    end
  end
end

ActiveRecord::Base.send(:include, MagicNumbers::ActiveRecord)
