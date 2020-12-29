# frozen_string_literal: true

require "mwrap"
require "objspace"
require_relative "../lib/rusty_json_schema"

# Based on examples from
# https://samsaffron.com/archive/2019/10/08/debugging-unmanaged-and-hidden-memory-leaks-in-ruby

def report_leaks # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  results = []

  Mwrap.each do |location, total, allocations, frees, _age_total, _max_lifespan| # rubocop:disable Metrics/ParameterLists
    results << [location, ((total / allocations.to_f) * (allocations - frees)), allocations, frees]
  end

  results.sort! do |(_, growth_a), (_, growth_b)|
    growth_b <=> growth_a
  end

  results.each do |location, growth, allocations, frees|
    next unless location.include?("libjson_schema.so")
    next if growth.zero?

    puts "#{location} growth: #{growth.to_i} allocs/frees (#{allocations}/#{frees})"
  end
end

def gc
  GC.start
  GC.respond_to?(:compact) && GC.compact
end

def usage
  rss = `ps -p #{Process.pid} -o rss -h`.strip.to_i * 1024

  puts "RSS: #{rss / 1024 / 1024}MB\tRuby Knows about: #{ObjectSpace.memsize_of_all / 1024 / 1024}MB"
end

SCHEMA  = File.read("spec/fixtures/small_schema.json")
VALID   = File.read("spec/fixtures/small_valid.json")
INVALID = File.read("spec/fixtures/small_invalid.json")

# Add code to verify & test here
#
# ## Example
#
#   validator = RustyJSONSchema.build(File.read("spec/fixtures/small_schema.json"))
#   event = File.read("spec/fixtures/small_invalid.json")
#
#   1000.times { validator.validate(event) }
#
def test_subject
  1000.times { RustyJSONSchema.build(SCHEMA).validate(INVALID) }
end

gc
usage
Mwrap.reset

test_subject

gc

# Don't track allocations for this block
Mwrap.quiet do
  report_leaks
  usage
end
