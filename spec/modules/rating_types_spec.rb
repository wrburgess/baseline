require "rails_helper"

RSpec.describe RatingTypes do
  describe "constants" do
    it "defines S" do
      expect(described_class::S).to eq("S")
    end

    it "defines C" do
      expect(described_class::C).to eq("C")
    end

    it "defines A" do
      expect(described_class::A).to eq("A")
    end

    it "defines M" do
      expect(described_class::M).to eq("M")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "S",
          "C",
          "A",
          "M"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::S).to be_frozen
      expect(described_class::C).to be_frozen
      expect(described_class::A).to be_frozen
      expect(described_class::M).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "S", "S" ],
          [ "C", "C" ],
          [ "A", "A" ],
          [ "M", "M" ]
        ]
      )
    end
  end
end
