require 'rspec'
require 'bcdatabase'

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'schema_qualified_tables'

module SqtCpk
  def test_cpk?
    ENV['CPK'] =~ /y|t/ || ENV['CPK'].nil?
  end
  module_function :test_cpk?
end

module DatabaseHelper
  def establish_connection
    ActiveRecord::Base.establish_connection(db_params)
  end

  def remove_connection
    ActiveRecord::Base.remove_connection
  end

  def db_params
    bcdb[bcdb_group, bcdb_entry]
  end

  private

  def bcdb_group
    ENV['SQT_DB_GROUP'] || :local_postgresql
  end

  def bcdb_entry
    ENV['SQT_DB_ENTRY'] || :schema_qualified_tables_test
  end

  def bcdb
    @bcdb ||= Bcdatabase.load
  end
end

module ARVersion
  def active_record_32_or_greater?
    begin
      Gem::Specification.find_by_name('activerecord', '>=3.2')
      true
    rescue Gem::LoadError
      false
    end
  end
end
include ARVersion

module SqtHelper
  module ClassMethods
    if active_record_32_or_greater?
      def sqt_table_name(name)
        self.table_name = name
      end

      def sqt_sequence_name(name)
        self.sequence_name = name
      end

      def sqt_schema_name(name)
        self.schema = name        
      end

      def sqt_primary_keys(*keys)
        self.primary_keys = keys
      end
    else
      def sqt_table_name(name)
        set_table_name(name)
      end

      def sqt_sequence_name(name)
        set_sequence_name(name)
      end

      def sqt_schema_name(name)
        set_schema(name)
      end

      def sqt_primary_keys(*keys)
        set_primary_keys(*keys)
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

::ActiveRecord::Base.send(:include, SqtHelper)

RSpec.configure do |config|
  config.include SqtCpk
  config.include DatabaseHelper
  config.include ARVersion
  config.treat_symbols_as_metadata_keys_with_true_values = true
end