require 'active_record'

module Bcdatabase
  module ActiveRecord
    module SchemaQualifiedTables
      def self.included(clz)
        clz.instance_eval do
          extend ClassMethods
          class_inheritable_accessor :schema

          class << self
            alias_method_chain :set_table_name, :schema
            alias_method_chain :set_sequence_name, :schema
          end
        end
      end

      module ClassMethods
        attr_accessor :schemas

        def set_schema(schema)
          self.schema = schema
          unless abstract_class?
            begin
              update_qualified_table_name
              update_qualified_sequence_name unless self.respond_to?(:primary_keys)
            rescue ::ActiveRecord::ConnectionNotEstablished
              # Defer
            end
          end
        end

        def set_table_name_with_schema(name)
          update_qualified_table_name(name)
        end

        def set_sequence_name_with_schema(name)
          if name
            update_qualified_sequence_name(name)
          else
            set_sequence_name_without_schema(name)
          end
        end

        def schemas
          @schemas ||= { }
        end

        protected

        def schema_name
          ::ActiveRecord::Base.schemas[self.schema] || self.schema
        end

        def update_qualified_table_name(table = nil)
          update_qualified(:table_name, table)
        end

        def update_qualified_sequence_name(sequence = nil)
          update_qualified(:sequence_name, sequence)
        end

        def update_qualified(thing, new_value)
          unless new_value
            current = self.send(thing) # invoke once only because of side effects
            new_value =
              if current.respond_to?(:include?) && current.include?('.')
                current.split('.', 2).last
              else
                current
              end
          end
          self.send(:"set_#{thing}_without_schema", nil) { new_value ? [schema_name, new_value].compact.join('.') : nil }
        end
      end
    end
  end
end

::ActiveRecord::Base.send(:include, Bcdatabase::ActiveRecord::SchemaQualifiedTables)
