require "rails_helper"

RSpec.describe MatchFormats do
  describe "constants" do
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
          "singles",
          "doubles"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::SINGLES).to be_frozen
      expect(described_class::DOUBLES).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Singles", "singles" ],
          [ "Doubles", "doubles" ]
        ]
      )
    end
  end
end
