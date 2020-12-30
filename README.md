# RustyJSONSchema

[![Gem Version](https://badge.fury.io/rb/rusty_json_schema.svg)](https://badge.fury.io/rb/rusty_json_schema)

FFI wrapper around [`jsonschema`](https://github.com/Stranger6667/jsonschema-rs) Rust library. Props go to original project.

Currently during heavy development.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rusty_json_schema"
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install rusty_json_schema
```

## Usage

Initialize schema validator

```ruby
validator = RustyJSONSchema.build(json_schema)
```

Validate events like

```ruby
validator.valid?(event_json)
# => true/false
```

To get validation errors

```ruby
validator.validate(event_json)
# => ["invalid...", ...]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

- update version number in `version.rb` & `CHANGELOG.md`
- create GitHub release with tag being new version prefixed with `v`, i.e. for `VERSION="0.1.0"` it would be `v0.1.0`
- pull `*.gem` artifact from release build
- `gem push *.gem` in order to publish it in [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/driv3r/rusty_json_schema. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/driv3r/rusty_json_schema/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RustyJSONSchema project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/driv3r/rusty_json_schema/blob/master/CODE_OF_CONDUCT.md).
