# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bcdatabase/active_record/schema_qualified_tables/version"

Gem::Specification.new do |s|
  s.name = %q{schema_qualified_tables}
  s.version = Bcdatabase::ActiveRecord::SchemaQualifiedTables::VERSION

  s.authors = ["Rhett Sutphin", "Peter Nyberg"]
  s.summary = %q{Logical schema names for ActiveRecord models}
  s.description = %q{An ActiveRecord mix-in that makes it easier to use AR in an application which contains models which map to tables in different schemas.}
  s.email = %q{rhett@detailedbalance.net}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = %q{http://github.com/NUBIC/schema_qualified_tables}
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', ['>= 2.3', '< 3.1']

  s.add_development_dependency 'rake', '~> 0.9.0'
  s.add_development_dependency 'rspec', '~> 1.2'
  s.add_development_dependency 'rcov'
  # the library is tested against CPK, but does not require it
  s.add_development_dependency 'composite_primary_keys'
  s.add_development_dependency 'ci_reporter', '~> 1.6.5'
end

