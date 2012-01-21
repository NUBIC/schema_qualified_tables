require 'bundler/gem_tasks'
require 'rake'

require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

desc 'Full CI build'
task :ci => ['ci:spec']

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  desc 'Run specs with ci_reporter'
  task :spec => ['ci:setup:rspec', 'rake:spec']
end

task :default => :spec
