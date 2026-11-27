# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run live specs (*_live_spec.rb) against the Jira test instance from .env"
task :live do
  files = Dir["spec/**/*_live_spec.rb"]
  abort "No live specs found" if files.empty?

  sh "bundle", "exec", "rspec", *files
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
