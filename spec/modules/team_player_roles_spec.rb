require "rails_helper"

RSpec.describe TeamPlayerRoles do
  describe "constants" do
    it "defines PLAYER" do
      expect(described_class::PLAYER).to eq("player")
    end

    it "defines CO_CAPTAIN" do
      expect(described_class::CO_CAPTAIN).to eq("co_captain")
    end

    it "defines CAPTAIN" do
      expect(described_class::CAPTAIN).to eq("captain")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "player",
          "co_captain",
          "captain"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::PLAYER).to be_frozen
      expect(described_class::CO_CAPTAIN).to be_frozen
      expect(described_class::CAPTAIN).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Player", "player" ],
          [ "Co Captain", "co_captain" ],
          [ "Captain", "captain" ]
        ]
      )
    end
  end
end
