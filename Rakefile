# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "thermite/tasks"

require_relative "lib/tasks/thermite_dir_patch"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
thermite = Thermite::Tasks.new

namespace :thermite do
  desc "Make existing extension default one"
  task :create_default do
    next unless File.exist?(thermite.config.ruby_extension_path)

    puts "Make #{thermite.config.ruby_extension_path} a #{Gem::Platform.local} default implementation"
    FileUtils.cp(thermite.config.ruby_extension_path,
                 "#{thermite.config.ruby_extension_path}.#{Gem::Platform.local}.default")
  end
end

Rake::Task["thermite:build"].enhance(["thermite:create_default"])

task default: %i[thermite:build thermite:test spec rubocop]
