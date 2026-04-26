require "rails_helper"

RSpec.describe GenderTypes do
  describe "constants" do
    it "defines MEN" do
      expect(described_class::MEN).to eq("men")
    end

    it "defines WOMEN" do
      expect(described_class::WOMEN).to eq("women")
    end

    it "defines MIXED" do
      expect(described_class::MIXED).to eq("mixed")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "men",
          "women",
          "mixed"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::MEN).to be_frozen
      expect(described_class::WOMEN).to be_frozen
      expect(described_class::MIXED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Men", "men" ],
          [ "Women", "women" ],
          [ "Mixed", "mixed" ]
        ]
      )
    end
  end
end
