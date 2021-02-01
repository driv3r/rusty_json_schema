# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "thermite/tasks"

require_relative "lib/tasks/thermite_dir_patch"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
thermite = Thermite::Tasks.new

desc "Make existing extension default one"
task build: ["thermite:build"] do
  unless File.exist?(thermite.config.ruby_extension_path)
    puts "File doesn't exist: #{thermite.config.ruby_extension_path.inspect}"
    next
  end

  platform = "#{Gem::Platform.local.cpu}-#{Gem::Platform.local.os}"

  puts "Make #{thermite.config.ruby_extension_path} a #{platform} default implementation"
  FileUtils.cp(thermite.config.ruby_extension_path,
               "#{thermite.config.ruby_extension_path}.#{platform}.default")
end

task default: %i[build thermite:test spec rubocop]
