# frozen_string_literal: true

module RustyJSONSchema

  # Integration point between Rust jsonschema wrapper
  # and RustyJSONSchema.
  #
  module Binding

    extend FFI::Library

    lib_name =
      case ::FFI::Platform::LIBSUFFIX
      when "so", "dylib" then "libjson_schema"
      when "dll" then "json_schema"
      end

    ffi_lib File.expand_path("../ext/#{lib_name}.#{::FFI::Platform::LIBSUFFIX}", __dir__)

    attach_function :new, :validator_new, [:string], Validator
    attach_function :free, :validator_free, [Validator], :void
    attach_function :free_array, :array_free, [NodesArray], :void
    attach_function :is_valid, :validator_is_valid, [Validator, :string], :bool
    attach_function :validate, :validator_validate, [Validator, :string], NodesArray.by_ref

  end

end
