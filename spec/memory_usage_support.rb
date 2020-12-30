# frozen_string_literal: true

require "rusty_json_schema"
require "tempfile"

module MemoryUsageSupport

  def self.gc!
    GC.start
    GC.respond_to?(:compact) && GC.compact
  end

  class Client

    attr_reader :report

    def initialize(wait: 10, sample: 1000)
      @wait = wait
      @sample = sample
    end

    def call
      MemoryUsageSupport.gc!
      start
      sleep @wait
      stop
    end

    def start
      @report_file = Tempfile.new("memory_report")
      @pid = fork do
        server = Server.new(report_file: @report_file.path, sample: @sample)
        server.usage
        server.setup_signal
        server.start
      end
    end

    def stop
      Process.kill("INT", @pid)
      Process.waitpid(@pid)
    end

    def generate_report
      @report ||= @report_file.read.split("\n").map(&:to_i)
    ensure
      @report_file.close
      @report_file.unlink
    end

  end

  class Server

    SCHEMA = TestSchemas.regular_schema
    VALID = TestSchemas.regular_event_valid
    INVALID = TestSchemas.regular_event_invalid

    def initialize(report_file:, sample: 1000)
      @stop = false
      @report_file = report_file
      @sample = sample
    end

    def setup_signal
      Signal.trap("INT") do
        @stop = true
      end
    end

    def start # rubocop:disable Metrics/MethodLength
      loop do
        break if @stop

        # Wrap within begin in order to ease up GC
        # with separate scope
        begin # rubocop:disable Style/RedundantBegin
          validators = Array.new(@sample) do
            RustyJSONSchema.build(SCHEMA)
          end

          validators.each do |validator|
            validator.valid?(VALID)
            validator.validate(VALID).to_a.empty?
            validator.valid?(INVALID)
            validator.validate(INVALID).to_a.empty?
          end
        end

        MemoryUsageSupport.gc!
        usage
        sleep 0.1
      end
    end

    # usage in kB
    def usage
      rss = `ps -p #{Process.pid} -o rss -h`.strip.to_i

      puts rss

      File.write(@report_file, "#{rss}\n", mode: "a")
    end

  end

end

client = MemoryUsageSupport::Client.new(wait: 30, sample: 1000)
client.call
client.generate_report

binding.irb # rubocop:disable Lint/Debugger
