source :rubygems

gemspec

# for testing against different major releases of ActiveRecord
if ENV['ACTIVERECORD_VERSION']
  version = case ENV['ACTIVERECORD_VERSION']
            when /2.3-old$/ then '= 2.3.8'
            when /2.3$/ then '~> 2.3.9'
            when /3.0$/ then '~> 3.0.0'
            when /3.1$/ then '~> 3.1.0'
            else raise "Unsupported ActiveRecord version #{ENV['ACTIVERECORD_VERSION']}"
            end

  gem 'activerecord', version
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
