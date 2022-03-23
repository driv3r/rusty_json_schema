# frozen_string_literal: true

RSpec.describe RustyJSONSchema do
  let(:schema) { File.read("spec/fixtures/canada_schema.json") }
  let(:event) { File.read("spec/fixtures/canada.json") }

  it "has a version number" do
    expect(RustyJSONSchema::VERSION).not_to be_nil
  end

  describe ".build" do
    it "returns new validator" do
      expect(described_class.build(schema)).to be_a RustyJSONSchema::Validator
    end
  end

  describe "#valid?" do
    subject(:validator) { described_class.build(schema) }

    context "when valid event" do
      it "validates event" do
        expect(validator.valid?(event)).to be true
      end
    end

    context "when invalid event" do
      let(:event) { "[10, 15]" }

      it "validates the event" do
        expect(validator.valid?(event)).to be false
      end
    end
  end

  describe "#validate" do
    subject(:validator) { described_class.build(schema) }

    let(:schema) do
      {
        properties: {
          foo: {
            type: "string"
          },
          bar: {
            type: "number"
          },
          baz: {}
        },
        required: ["baz"]
      }
    end

    context "when valid event" do
      let(:event) { { "foo" => "rusty", "bar" => 1, "baz" => "rusty" } }

      it "returns empty array" do
        expect(validator.validate(event)).to eq []
      end
    end

    context "when invalid event" do
      let(:event) { { "foo" => 1, "bar" => "rusty" } }

      it "returns validation errors" do
        expect(validator.validate(event)).to eq [
          %(path "/bar": "rusty" is not of type "number"),
          %(path "/foo": 1 is not of type "string"),
          %(path "/": "baz" is a required property)
        ]
      end
    end
  end
end
