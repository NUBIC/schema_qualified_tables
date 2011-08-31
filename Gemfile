source :rubygems

gemspec

# for testing against different major releases of ActiveRecord
if ENV['ACTIVERECORD_VERSION']
  version = case ENV['ACTIVERECORD_VERSION']
            when /2.3$/ then '~> 2.3.0'
            when /3.0$/ then '~> 3.0.0'
            else raise "Unsupported ActiveRecord version #{ENV['ACTIVERECORD_VERSION']}"
            end

  gem 'activerecord', version
end
