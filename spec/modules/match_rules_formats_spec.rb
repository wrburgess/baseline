require "rails_helper"

RSpec.describe MatchRulesFormats do
  describe "constants" do
    it "defines BEST_OF_3_STANDARD" do
      expect(described_class::BEST_OF_3_STANDARD).to eq("best_of_3_standard")
    end

    it "defines BEST_OF_3_MATCH_TB" do
      expect(described_class::BEST_OF_3_MATCH_TB).to eq("best_of_3_match_tb")
    end

    it "defines FAST4" do
      expect(described_class::FAST4).to eq("fast4")
    end

    it "defines PRO_SET_8" do
      expect(described_class::PRO_SET_8).to eq("pro_set_8")
    end

    it "defines PRO_SET_10" do
      expect(described_class::PRO_SET_10).to eq("pro_set_10")
    end

    it "defines MATCH_TB_10" do
      expect(described_class::MATCH_TB_10).to eq("match_tb_10")
    end

    it "defines MATCH_TB_7" do
      expect(described_class::MATCH_TB_7).to eq("match_tb_7")
    end

    it "defines CUSTOM" do
      expect(described_class::CUSTOM).to eq("custom")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "best_of_3_standard",
          "best_of_3_match_tb",
          "fast4",
          "pro_set_8",
          "pro_set_10",
          "match_tb_10",
          "match_tb_7",
          "custom"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::BEST_OF_3_STANDARD).to be_frozen
      expect(described_class::BEST_OF_3_MATCH_TB).to be_frozen
      expect(described_class::FAST4).to be_frozen
      expect(described_class::PRO_SET_8).to be_frozen
      expect(described_class::PRO_SET_10).to be_frozen
      expect(described_class::MATCH_TB_10).to be_frozen
      expect(described_class::MATCH_TB_7).to be_frozen
      expect(described_class::CUSTOM).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Best Of 3 Standard", "best_of_3_standard" ],
          [ "Best Of 3 Match Tb", "best_of_3_match_tb" ],
          [ "Fast4", "fast4" ],
          [ "Pro Set 8", "pro_set_8" ],
          [ "Pro Set 10", "pro_set_10" ],
          [ "Match Tb 10", "match_tb_10" ],
          [ "Match Tb 7", "match_tb_7" ],
          [ "Custom", "custom" ]
        ]
      )
    end
  end
end
