# frozen_string_literal: true
# rubocop:disable
require "benchmark/ips"
require "json"

require "json_schemer"

require_relative "../lib/rusty_json_schema"
require_relative "support/test_schemas"

tests = {
  tiny: {
    schema: TestSchemas.regular_schema,
    events: [
      {
        valid: true,
        event: TestSchemas.regular_event_valid,
        results: {}
      },
      {
        valid: false,
        event: TestSchemas.regular_event_invalid,
        results: {}
      }
    ]
  },
  small: {
    schema: TestSchemas.small_schema,
    events: [
      {
        valid: true,
        event: TestSchemas.small_event_valid,
        results: {}
      },
      {
        valid: false,
        event: TestSchemas.small_event_invalid,
        results: {}
      }
    ]
  },
  big: {
    config: {
      time: 30,
      warmup: 6
    },
    schema: TestSchemas.big_schema,
    events: [
      {
        valid: true,
        event: TestSchemas.big_event,
        results: {}
      }
    ]
  }
}

tests.each do |schema, specs|
  validators = {
    RustyJSONSchema: RustyJSONSchema.build(specs[:schema]),
    JSONSchemer: JSONSchemer.schema(specs[:schema])
  }

  specs[:events].each do |event|
    puts "\n=========================================\n#{schema} schema: #{event[:valid] ? "" : "in"}valid event => #valid?"
    event[:results][:valid?] = Benchmark.ips do |x|
      x.config(specs[:config]) if specs.key?(:config)

      validators.each do |name, validator|
        x.report(name) do
          validator.valid?(event[:event])
        end
      end

      x.compare!
    end

    puts "\n#{schema} schema: #{event[:valid] ? "" : "in"}valid event => #validate"
    event[:results][:validate] = Benchmark.ips do |x|
      x.config(specs[:config]) if specs.key?(:config)

      validators.each do |name, validator|
        x.report(name) do
          validator.validate(event[:event]).to_a
        end
      end

      x.compare!
    end
  end
end

HEADER = <<STR
# Benchmarks

Compare various gems doing json schema validation.

At the moment we are only looking at gems implementing Draft 7 of json schema.

Update by running:

```bash
bundle exec ruby spec/benchmark.rb
```

> Run against:
>
> - #{`uname -v -r`.split(" ").take(2).reverse.join(" @ kernel: ")}
> - AMD Ryzen 9 3900X 12-Core
> - 32GB RAM

STR

TABLE_HEADER = <<STR
  <thead>
    <tr>
      <th rowspan=2 >Gem</th>
      <th colspan=2 >Tiny Schema</th>
      <th colspan=2 >Schema</th>
      <th >Big Schema</th>
    </tr>
    <tr>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
      <th>Invalid</th>
      <th>Valid</th>
    </tr>
  </thead>
STR

DESC = {
  valid?: "Simple boolean result.",
  validate: "Returns a list of validation errors if any"
}.freeze

GEMS_ORDER = %i[RustyJSONSchema JSONSchemer].freeze
TESTS_ORDER = %i[tiny_valid tiny_invalid small_valid small_invalid big_valid].freeze

def update_results(tests)
  results = {
    valid?: {},
    validate: {}
  }

  tests.each do |schema, specs|
    specs[:events].each do |event|
      name = "#{schema}_#{event[:valid] ? "valid" : "invalid"}".to_sym

      gen_results(event[:results][:valid?].entries, results[:valid?], name)
      gen_results(event[:results][:validate].entries, results[:validate], name)
    end
  end

  File.open("BENCHMARK.md", mode: "w") do |f|
    f.write(HEADER)

    results.each do |method, result|
      f.write <<~STR
        ## Gem##{method}

        #{DESC[method]}

        > Results in instructions/validations per second.

        <table>
        #{TABLE_HEADER}
          <tbody>
      STR

      GEMS_ORDER.each do |gem_name|
        to_write = ["    <tr>", "      <th>#{gem_name}</th>"]
        TESTS_ORDER.each do |test_name|
          to_write << "      <td>#{result[gem_name][test_name]}</td>"
        end
        to_write << "    </tr>\n"
        f.write(to_write.join("\n"))
      end

      f.write("  </tbody>\n</table>\n\n")
    end
  end
end

def gen_results(entries, results, test_name)
  sorted = entries.sort_by { |e| e.stats.central_tendency }
                  .reverse

  best = sorted.shift

  results[gem_name(best)] ||= {}
  results[gem_name(best)][test_name] = format("%10.1f", best.stats.central_tendency)

  sorted.each do |report|
    extra =
      if report.stats.overlaps?(best.stats)
        "same-ish"
      else
        slowdown, error = report.stats.slowdown(best.stats)

        str = format("%.2fx ", slowdown)
        str = format("#{str} (± %.2f)", error) if error && error > 0.01

        str
      end

    results[gem_name(report)] ||= {}
    results[gem_name(report)][test_name] = format("%10.1f - %s", report.stats.central_tendency, extra)
  end
end

def gem_name(entry)
  entry.label.to_s.to_sym
end

update_results(tests)
