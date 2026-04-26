require "rails_helper"

RSpec.describe MatchOutcomes do
  describe "constants" do
    it "defines COMPLETED" do
      expect(described_class::COMPLETED).to eq("completed")
    end

    it "defines RETIRED" do
      expect(described_class::RETIRED).to eq("retired")
    end

    it "defines DEFAULTED" do
      expect(described_class::DEFAULTED).to eq("defaulted")
    end

    it "defines WALKOVER" do
      expect(described_class::WALKOVER).to eq("walkover")
    end

    it "defines TIMED" do
      expect(described_class::TIMED).to eq("timed")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "completed",
          "retired",
          "defaulted",
          "walkover",
          "timed"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::COMPLETED).to be_frozen
      expect(described_class::RETIRED).to be_frozen
      expect(described_class::DEFAULTED).to be_frozen
      expect(described_class::WALKOVER).to be_frozen
      expect(described_class::TIMED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Completed", "completed" ],
          [ "Retired", "retired" ],
          [ "Defaulted", "defaulted" ],
          [ "Walkover", "walkover" ],
          [ "Timed", "timed" ]
        ]
      )
    end
  end
end
