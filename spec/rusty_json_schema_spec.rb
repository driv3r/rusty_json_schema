# frozen_string_literal: true

RSpec.describe RustyJSONSchema do
  let(:schema) { File.read("spec/fixtures/canada_schema.json") }
  let(:event) { File.read("spec/fixtures/canada.json") }

  it "has a version number" do
    expect(RustyJSONSchema::VERSION).not_to be nil
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
        expect(validator.valid?(event)).to eq true
      end
    end

    context "when invalid event" do
      let(:event) { "[10, 15]" }

      it "validates the event" do
        expect(validator.valid?(event)).to eq false
      end
    end
  end
end
