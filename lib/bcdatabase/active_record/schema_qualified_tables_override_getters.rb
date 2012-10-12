require 'active_record'

module Bcdatabase
  module ActiveRecord
    module SchemaQualifiedTables
      def self.included(clz)
        clz.instance_eval do
          extend ClassMethods
          if self.respond_to?(:class_attribute)
            class_attribute :schema
          elsif self.respond_to?(:class_inheritable_accessor)
            class_inheritable_accessor :schema
          else
            fail "schema_qualified_tables is apparently not compatible with this version of ActiveRecord. Please report this as a bug."
          end
        end
      end

      module ClassMethods
        attr_accessor :schemas
        attr_writer :schema

        def table_name
          unless abstract_class?
            if schema_name_prepended?(schema_name, super)
              super
            else
              "#{schema_name}.#{super}"
            end
          end
        end

        def sequence_name
          unless abstract_class?
            if schema_name_prepended?(schema_name, super)
              super
            else
              "#{schema_name}.#{super}"
            end
          end
        end

        # Support pre-rails 3.2 style setter
        def set_schema(schema)
          self.schema = schema
        end

        def schemas
          @schemas ||= { }
        end

        protected

        def schema_name_prepended?(name, super_klass)
          !(name && (super_klass =~ /^#{name}\./).nil?)
        end

        def schema_name
          ::ActiveRecord::Base.schemas[self.schema] || self.schema
        end
      end
    end
  end
end

::ActiveRecord::Base.send(:include, Bcdatabase::ActiveRecord::SchemaQualifiedTables)
