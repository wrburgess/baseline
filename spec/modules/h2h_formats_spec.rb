require "rails_helper"

RSpec.describe H2HFormats do
  describe "constants" do
    it "defines ALL" do
      expect(described_class::ALL).to eq("all")
    end

    it "defines SINGLES" do
      expect(described_class::SINGLES).to eq("singles")
    end

    it "defines DOUBLES" do
      expect(described_class::DOUBLES).to eq("doubles")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "all",
          "singles",
          "doubles"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::ALL).to be_frozen
      expect(described_class::SINGLES).to be_frozen
      expect(described_class::DOUBLES).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "All", "all" ],
          [ "Singles", "singles" ],
          [ "Doubles", "doubles" ]
        ]
      )
    end
  end
end
