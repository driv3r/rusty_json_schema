# frozen_string_literal: true

module RustyJSONSchema

  # Struct representing list of errors returned from
  # our wrapper library. Use ManagedStruct in order to
  # properly release nested strings which would otherwise
  # leak and pollute the memory.
  #
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

end
