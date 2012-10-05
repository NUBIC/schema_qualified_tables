begin
  Gem::Specification.find_by_name('activerecord', '>=3.2')
  require 'bcdatabase/active_record/schema_qualified_tables_override_getters'
rescue Gem::LoadError
  require 'bcdatabase/active_record/schema_qualified_tables_override_setters'
end
