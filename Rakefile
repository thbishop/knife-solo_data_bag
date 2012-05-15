#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => [:spec]

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fs --color)
end
