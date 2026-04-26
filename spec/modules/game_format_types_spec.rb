require "rails_helper"

RSpec.describe GameFormatTypes do
  describe "constants" do
    it "defines LEVEL" do
      expect(described_class::LEVEL).to eq("level")
    end

    it "defines TRI_LEVEL" do
      expect(described_class::TRI_LEVEL).to eq("tri_level")
    end

    it "defines MIXED_DOUBLES" do
      expect(described_class::MIXED_DOUBLES).to eq("mixed_doubles")
    end

    it "defines COMBO_DOUBLES" do
      expect(described_class::COMBO_DOUBLES).to eq("combo_doubles")
    end

    it "defines SINGLES_ONLY" do
      expect(described_class::SINGLES_ONLY).to eq("singles_only")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "level",
          "tri_level",
          "mixed_doubles",
          "combo_doubles",
          "singles_only"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::LEVEL).to be_frozen
      expect(described_class::TRI_LEVEL).to be_frozen
      expect(described_class::MIXED_DOUBLES).to be_frozen
      expect(described_class::COMBO_DOUBLES).to be_frozen
      expect(described_class::SINGLES_ONLY).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Level", "level" ],
          [ "Tri Level", "tri_level" ],
          [ "Mixed Doubles", "mixed_doubles" ],
          [ "Combo Doubles", "combo_doubles" ],
          [ "Singles Only", "singles_only" ]
        ]
      )
    end
  end
end
