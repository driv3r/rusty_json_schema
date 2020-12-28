# frozen_string_literal: true

require "benchmark/ips"
require "json_schemer"
require "rusty_json_schema"
require "json"

big_schema = File.read("spec/fixtures/canada_schema.json")
big_schema_hash = JSON.parse(big_schema)
big_event = File.read("spec/fixtures/canada.json")
big_event_hash = JSON.parse(big_event)

small_schema = File.read("spec/fixtures/small_schema.json")
small_schema_hash = JSON.parse(small_schema)
small_event = File.read("spec/fixtures/small_valid.json")
small_event_hash = JSON.parse(small_event)
small_invalid_event = File.read("spec/fixtures/small_invalid.json")
small_invalid_event_hash = JSON.parse(small_invalid_event)

big_validator = RustyJSONSchema.build(big_schema)
big_schemer = JSONSchemer.schema(big_schema_hash)
small_validator = RustyJSONSchema.build(small_schema)
small_schemer = JSONSchemer.schema(small_schema_hash)

Benchmark.ips do |x|
  x.config(time: 30, warmup: 6)

  x.report("big validator") { raise "foo" unless big_validator.valid?(big_event) }
  x.report("big schemer") { raise "foo" unless big_schemer.valid?(big_event_hash) }

  x.compare!
end

Benchmark.ips do |x|
  x.report("small validator: valid") { raise "foo" unless small_validator.valid?(small_event) }
  x.report("small schemer:   valid") { raise "foo" unless small_schemer.valid?(small_event_hash) }

  x.compare!
end

Benchmark.ips do |x|
  x.report("small validator: invalid") { raise "foo" if small_validator.valid?(small_invalid_event) }
  x.report("small schemer:   invalid") { raise "foo" if small_schemer.valid?(small_invalid_event_hash) }

  x.compare!
end
