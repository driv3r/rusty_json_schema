# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.1]
### Changed
- Update `jsonschema` dependency
- Update minimum Ruby version to 2.6

## [0.5.0]
### Changed
- Update `jsonschema` dependency
- Match versioning with `jsonschema`

## [0.3.2]
### Changed
- Support broader range of MacOS systems with prebuild binaries
- Cleanup default prebuild binaries after gem installation to reduce used disc space

## [0.3.1]
### Changed
- Package pre-build binaries together

## [0.3.0]
### Added
- Compile gem during installation when rustc is available

### Changed
- Build per platform, reducing total size of a single gem
- Providing default binary for platform

## [0.2.0]
### Added
- `validate` function returning array of error messages.
- tooling for testing memory usage locally

## [0.1.0]
### Added
- Basic FFI bindings with simple validation implementation. Ensured that memory usage is ok.

## [0.0.1]
### Added
- basic gem structure
