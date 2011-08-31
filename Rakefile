require 'bundler/gem_tasks'
require 'rake'

require 'spec/rake/spectask'
require 'ci/reporter/rake/rspec'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
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
