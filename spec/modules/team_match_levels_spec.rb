require "rails_helper"

RSpec.describe TeamMatchLevels do
  describe "constants" do
    it "defines REGULAR_SEASON" do
      expect(described_class::REGULAR_SEASON).to eq("regular_season")
    end

    it "defines LOCAL_PLAYOFF" do
      expect(described_class::LOCAL_PLAYOFF).to eq("local_playoff")
    end

    it "defines DISTRICT" do
      expect(described_class::DISTRICT).to eq("district")
    end

    it "defines SECTION" do
      expect(described_class::SECTION).to eq("section")
    end

    it "defines NATIONAL" do
      expect(described_class::NATIONAL).to eq("national")
    end

    it "defines TOURNAMENT" do
      expect(described_class::TOURNAMENT).to eq("tournament")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "regular_season",
          "local_playoff",
          "district",
          "section",
          "national",
          "tournament"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::REGULAR_SEASON).to be_frozen
      expect(described_class::LOCAL_PLAYOFF).to be_frozen
      expect(described_class::DISTRICT).to be_frozen
      expect(described_class::SECTION).to be_frozen
      expect(described_class::NATIONAL).to be_frozen
      expect(described_class::TOURNAMENT).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Regular Season", "regular_season" ],
          [ "Local Playoff", "local_playoff" ],
          [ "District", "district" ],
          [ "Section", "section" ],
          [ "National", "national" ],
          [ "Tournament", "tournament" ]
        ]
      )
    end
  end
end
