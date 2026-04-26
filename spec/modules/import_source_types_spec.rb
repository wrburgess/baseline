require "rails_helper"

RSpec.describe ImportSourceTypes do
  describe "constants" do
    it "defines TENNISLINK_TEAM_PAGE" do
      expect(described_class::TENNISLINK_TEAM_PAGE).to eq("tennislink_team_page")
    end

    it "defines TENNISLINK_MATCH_RESULTS" do
      expect(described_class::TENNISLINK_MATCH_RESULTS).to eq("tennislink_match_results")
    end

    it "defines TENNISLINK_SCHEDULE_PAGE" do
      expect(described_class::TENNISLINK_SCHEDULE_PAGE).to eq("tennislink_schedule_page")
    end

    it "defines TENNISRECORD_PLAYER_PAGE" do
      expect(described_class::TENNISRECORD_PLAYER_PAGE).to eq("tennisrecord_player_page")
    end

    it "defines WTN_PLAYER_PAGE" do
      expect(described_class::WTN_PLAYER_PAGE).to eq("wtn_player_page")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "tennislink_team_page",
          "tennislink_match_results",
          "tennislink_schedule_page",
          "tennisrecord_player_page",
          "wtn_player_page"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::TENNISLINK_TEAM_PAGE).to be_frozen
      expect(described_class::TENNISLINK_MATCH_RESULTS).to be_frozen
      expect(described_class::TENNISLINK_SCHEDULE_PAGE).to be_frozen
      expect(described_class::TENNISRECORD_PLAYER_PAGE).to be_frozen
      expect(described_class::WTN_PLAYER_PAGE).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Tennislink Team Page", "tennislink_team_page" ],
          [ "Tennislink Match Results", "tennislink_match_results" ],
          [ "Tennislink Schedule Page", "tennislink_schedule_page" ],
          [ "Tennisrecord Player Page", "tennisrecord_player_page" ],
          [ "Wtn Player Page", "wtn_player_page" ]
        ]
      )
    end
  end
end
