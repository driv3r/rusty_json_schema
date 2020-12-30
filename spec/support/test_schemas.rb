# frozen_string_literal: true

module TestSchemas

  module_function

  def big_schema
    load_fixture("canada_schema")
  end

  def big_event
    load_fixture("canada")
  end

  def regular_schema
    load_fixture("schema")
  end

  def regular_event_valid
    load_fixture("event_valid")
  end

  def regular_event_invalid
    load_fixture("event_invalid")
  end

  def small_schema
    load_fixture("small_schema")
  end

  def small_event_valid
    load_fixture("small_valid")
  end

  def small_event_invalid
    load_fixture("small_invalid")
  end

  def load_fixture(schema)
    JSON.parse(File.read("spec/fixtures/#{schema}.json"))
  end

end
