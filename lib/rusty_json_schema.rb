# frozen_string_literal: true

require "ffi"
require "json"

require "rusty_json_schema/version"
require "rusty_json_schema/nodes_array"
require "rusty_json_schema/validator"
require "rusty_json_schema/binding"

# JSON Schema validation
#
# ## Example
#
#     validator = RustyJSONSchema.build(schema)
#
#     validator.valid?(event)
#     # => true/false
#
#     validator.validate(event)
#     # => [] / ["...error messages", ...]
#
module RustyJSONSchema

  class Error < StandardError; end

  class << self

    attr_writer :processor

    def processor
      @processor ||= JSON
    end

    def dump(data)
      case data
      when String then data
      else processor.dump(data)
      end
    end

    # Helper method that returns new instance of pointer
    # to Validator struct.
    #
    def build(schema)
      RustyJSONSchema::Binding.new(dump(schema))
    end

  end

end
