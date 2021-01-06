# frozen_string_literal: true

require_relative "lib/rusty_json_schema/version"

Gem::Specification.new do |spec|
  spec.name        = "rusty_json_schema"
  spec.version     = RustyJSONSchema::VERSION
  spec.authors     = ["Leszek Zalewski"]
  spec.email       = ["leszekzalewski@fastmail.fm"]
  spec.license     = "MIT"
  spec.homepage    = "https://github.com/driv3r/rusty_json_schema"
  spec.summary     = "FFI wrapper around jsonschema-rs Rust library."
  spec.description = <<-STR
    FFI wrapper around https://github.com/Stranger6667/jsonschema-rs Rust library.

    Currently during heavy development.
  STR

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "https://github.com/driv3r/rusty_json_schema/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "src/**/*.rs", "rusty_json_schema.gemspec", "Cargo.toml", "LICENSE", "README.md"]

  spec.require_paths = ["lib"]

  spec.extensions << "ext/Rakefile"
  spec.add_runtime_dependency "thermite", "~> 0"

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ffi", "~> 1.14"
  spec.add_dependency "json", ">= 1.0"
end
