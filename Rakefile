# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task :rust_build do
  `cargo rustc --release`
  `mv -f ./target/release/libjson_schema.so ./lib/ext/`
end

task default: %i[rust_build spec rubocop]
