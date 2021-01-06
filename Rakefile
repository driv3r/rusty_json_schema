# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "thermite/tasks"

require_relative "lib/tasks/thermite_dir_patch"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Thermite::Tasks.new

task default: %i[thermite:build thermite:test spec rubocop]
