# frozen_string_literal: true

# Update where this option is configurable
# is not yet released
module ThermiteDirPatch

  def ruby_extension_path
    ruby_path("ext", shared_library)
  end

end

Thermite::Config.prepend(ThermiteDirPatch)
