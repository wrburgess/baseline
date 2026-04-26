require "rails_helper"

RSpec.describe ImportKinds do
  describe "constants" do
    it "defines TEAM_ROSTER" do
      expect(described_class::TEAM_ROSTER).to eq("team_roster")
    end

    it "defines MATCH_NIGHT" do
      expect(described_class::MATCH_NIGHT).to eq("match_night")
    end

    it "defines PLAYER_RATINGS" do
      expect(described_class::PLAYER_RATINGS).to eq("player_ratings")
    end

    it "defines LEAGUE_SCHEDULE" do
      expect(described_class::LEAGUE_SCHEDULE).to eq("league_schedule")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "team_roster",
          "match_night",
          "player_ratings",
          "league_schedule"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::TEAM_ROSTER).to be_frozen
      expect(described_class::MATCH_NIGHT).to be_frozen
      expect(described_class::PLAYER_RATINGS).to be_frozen
      expect(described_class::LEAGUE_SCHEDULE).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Team Roster", "team_roster" ],
          [ "Match Night", "match_night" ],
          [ "Player Ratings", "player_ratings" ],
          [ "League Schedule", "league_schedule" ]
        ]
      )
    end
  end
end
