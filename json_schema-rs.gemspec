# frozen_string_literal: true

require_relative "lib/json_schema/version"

Gem::Specification.new do |spec|
  spec.name          = "json_schema-rs"
  spec.version       = JsonSchema::VERSION
  spec.authors       = ["Leszek Zalewski"]
  spec.email         = ["leszekzalewski@fastmail.fm"]

  spec.summary       = "FFI wrapper around json_schema-rs rust library."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/driv3r/json_schema-rs"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/driv3r/json_schema-rs/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "src/**/*.rs", "json_schema-rs.gemspec", "Cargo.toml", "LICENSE", "README.md"]

  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ffi"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
