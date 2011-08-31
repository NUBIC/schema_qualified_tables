require 'bundler/gem_tasks'
require 'rake'

require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  # rcov can't tell that /Library/Ruby and RVM are system paths
  spec.rcov_opts = ['--exclude', "spec/*,/Library/Ruby/*,#{ENV['HOME']}/.rvm/*"]
end

desc 'Full CI build'
task :ci => ['ci:spec']

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  desc 'Run specs with coverage and ci_reporter'
  task :spec => ['ci:setup:rspec', 'rake:rcov']
end

task :default => :spec
