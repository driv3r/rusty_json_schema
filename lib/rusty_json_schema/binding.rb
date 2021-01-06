# frozen_string_literal: true

module RustyJSONSchema

  # Integration point between Rust jsonschema wrapper
  # and RustyJSONSchema.
  #
  module Binding

    extend FFI::Library

    ffi_lib File.expand_path("../../ext/json_schema.so", __dir__)

    attach_function :new, :validator_new, [:string], Validator
    attach_function :free, :validator_free, [Validator], :void
    attach_function :free_array, :array_free, [NodesArray], :void
    attach_function :is_valid, :validator_is_valid, [Validator, :string], :bool
    attach_function :validate, :validator_validate, [Validator, :string], NodesArray.by_ref

  end

end
