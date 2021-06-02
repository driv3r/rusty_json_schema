# frozen_string_literal: true

module RustyJSONSchema

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
    # ## Examples
    #
    #     validator = RustyJSONSchema.build(json_schema)
    #     validator.valid?(event)
    #     # => false|true
    #
    def valid?(event)
      Binding.is_valid(self, RustyJSONSchema.dump(event))
    end

    # Full validation and error messages
    #
    # ## Examples
    #
    #     validator = RustyJSONSchema.build(json_schema)
    #     validator.validate(event)
    #     # => [
    #     #   'path "/foo": "rusty" is not a "number"',
    #     #   ...
    #     # ]
    #
    def validate(event)
      Binding.validate(self, RustyJSONSchema.dump(event)).to_a
    end

  end

end
