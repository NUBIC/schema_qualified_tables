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

RSpec.configure do |config|
  config.include SqtCpk
  config.include DatabaseHelper
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
