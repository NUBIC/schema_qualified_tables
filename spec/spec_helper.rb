require 'rspec'

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'bcdatabase/active_record/schema_qualified_tables'

module SqtCpk
  def test_cpk?
    ENV['CPK'] =~ /y|t/ || ENV['CPK'].nil?
  end
  module_function :test_cpk?
end

RSpec.configure do |config|
  config.include SqtCpk
end
