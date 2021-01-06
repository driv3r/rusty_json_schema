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
  desc "Unpack thermite build package"
  task :unpack do
    package_name = thermite.config.tarball_filename(thermite.config.crate_version)

    raise ArgumentError, "missing #{package_name.inspect}" unless File.exist?(package_name)

    puts "Unpacking: #{package_name.inspect}"
    Zlib::GzipReader.open(package_name) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        tar.each do |entry|
          path = entry.header.name
          next if path.end_with?("/")

          puts "Unpacking file: #{path}"

          File.open(path, "wb") do |f|
            f.write(entry.read)
          end
        end
      end
    end

    thermite.prepare_downloaded_library
  end
end

task default: %i[thermite:build thermite:test spec rubocop]
