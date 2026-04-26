require "rails_helper"

RSpec.describe AgeLevels do
  describe "constants" do
    it "defines AGE_18_PLUS" do
      expect(described_class::AGE_18_PLUS).to eq("18_plus")
    end

    it "defines AGE_40_PLUS" do
      expect(described_class::AGE_40_PLUS).to eq("40_plus")
    end

    it "defines AGE_55_PLUS" do
      expect(described_class::AGE_55_PLUS).to eq("55_plus")
    end

    it "defines AGE_65_PLUS" do
      expect(described_class::AGE_65_PLUS).to eq("65_plus")
    end

    it "defines AGE_70_PLUS" do
      expect(described_class::AGE_70_PLUS).to eq("70_plus")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "18_plus",
          "40_plus",
          "55_plus",
          "65_plus",
          "70_plus"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::AGE_18_PLUS).to be_frozen
      expect(described_class::AGE_40_PLUS).to be_frozen
      expect(described_class::AGE_55_PLUS).to be_frozen
      expect(described_class::AGE_65_PLUS).to be_frozen
      expect(described_class::AGE_70_PLUS).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "18 Plus", "18_plus" ],
          [ "40 Plus", "40_plus" ],
          [ "55 Plus", "55_plus" ],
          [ "65 Plus", "65_plus" ],
          [ "70 Plus", "70_plus" ]
        ]
      )
    end
  end
end
