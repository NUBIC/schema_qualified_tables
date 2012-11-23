source :rubygems

gemspec

# for testing against different major releases of ActiveRecord
if ENV['ACTIVERECORD_VERSION']
  version = case ENV['ACTIVERECORD_VERSION']
            when /2.3-old$/ then '= 2.3.8'
            when /2.3$/ then '~> 2.3.9'
            when /3.0$/ then '~> 3.0.10'
            when /3.1$/ then '~> 3.1.0'
            when /3.2$/ then '~> 3.2.0'
            else raise "Unsupported ActiveRecord version #{ENV['ACTIVERECORD_VERSION']}"
            end

  gem 'activerecord', version

  # Force CPK version for pre-AR 3.2 to work around https://github.com/rubygems/bundler-api/issues/17
  # Once that issue has been fixed in the rubygems.org data, this should be removed.
  unless ENV['ACTIVERECORD_VERSION'] =~ /3.2$/
    gem 'composite_primary_keys', '< 5'
  end
end

group :postgresql do
  platforms :ruby_18, :ruby_19 do
    gem 'pg', '~> 0.11.0'
  end

  platforms :jruby do
    gem 'activerecord-jdbcpostgresql-adapter'
  end
end

if ENV['SQT_ORACLE']
  group :oracle do
    gem 'activerecord-oracle_enhanced-adapter'

    platforms :ruby_18, :ruby_19 do
      gem 'ruby-oci8'
    end
  end
end
