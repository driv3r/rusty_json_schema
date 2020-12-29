# frozen_string_literal: true

require "ffi"
require "json"

require_relative "rusty_json_schema/version"

# JSON Schema validation
#
# ## Example
#
#     validator = RustyJSONSchema.build(schema) # where schema is a json string of the schema
#     validator.valid?(event) # where event is a json string of schema
#     # => true/false
#
module RustyJSONSchema

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

    def build(schema)
      RustyJSONSchema::Validator::Binding.new(dump(schema))
    end

  end

  class Error < StandardError; end

  # Handles release of the pointer automatically
  # with Ruby GC. This way we can intialize validator
  # in Rust, and hold a reference in Ruby.
  #
  class Validator < FFI::AutoPointer

    # Custom GC flow for our validator, freeing
    # the object within Rust
    #
    def self.release(pointer)
      Binding.free(pointer)
    end

    # Simple validation without actual error messages
    #
    def valid?(event)
      Binding.is_valid(self, RustyJSONSchema.dump(event))
    end

    def validate(event)
      Binding.validate(self, RustyJSONSchema.dump(event)).to_a
    end

    # FFI container for our library.
    #
    module Binding

      extend FFI::Library

      lib_name =
        case ::FFI::Platform::LIBSUFFIX
        when "so", "dylib" then "libjson_schema"
        when "dll" then "json_schema"
        end

      ffi_lib File.expand_path("ext/#{lib_name}.#{::FFI::Platform::LIBSUFFIX}", __dir__)

      # nodoc
      class NodesArray < FFI::ManagedStruct

        layout :data, :pointer,
               :len,  :uint,
               :cap,  :uint

        def to_a
          self[:data].get_array_of_string(0, self[:len]).compact
        end

        def self.release(ptr)
          Binding.free_array(ptr)
        end

      end

      attach_function :new, :validator_new, [:string], Validator
      attach_function :free, :validator_free, [Validator], :void
      attach_function :free_array, :array_free, [NodesArray], :void
      attach_function :is_valid, :validator_is_valid, [Validator, :string], :bool
      attach_function :validate, :validator_validate, [Validator, :string], NodesArray.by_ref

    end

  end

end
