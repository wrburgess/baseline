require "rails_helper"

RSpec.describe MatchSides do
  describe "constants" do
    it "defines HOME" do
      expect(described_class::HOME).to eq("home")
    end

    it "defines AWAY" do
      expect(described_class::AWAY).to eq("away")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "home",
          "away"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::HOME).to be_frozen
      expect(described_class::AWAY).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Home", "home" ],
          [ "Away", "away" ]
        ]
      )
    end
  end
end
