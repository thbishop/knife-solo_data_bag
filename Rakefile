#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => [:spec]

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format documentation --color)
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end
