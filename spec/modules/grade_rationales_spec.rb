require "rails_helper"

RSpec.describe GradeRationales do
  describe "constants" do
    it "defines SELF_RATED" do
      expect(described_class::SELF_RATED).to eq("self_rated")
    end

    it "defines YEAR_END_COMPUTER" do
      expect(described_class::YEAR_END_COMPUTER).to eq("year_end_computer")
    end

    it "defines EARLY_START_BUMP" do
      expect(described_class::EARLY_START_BUMP).to eq("early_start_bump")
    end

    it "defines MID_YEAR_BUMP" do
      expect(described_class::MID_YEAR_BUMP).to eq("mid_year_bump")
    end

    it "defines THREE_STRIKE_DQ" do
      expect(described_class::THREE_STRIKE_DQ).to eq("three_strike_dq")
    end

    it "defines APPEAL_GRANTED" do
      expect(described_class::APPEAL_GRANTED).to eq("appeal_granted")
    end

    it "defines APPEAL_DENIED" do
      expect(described_class::APPEAL_DENIED).to eq("appeal_denied")
    end

    it "defines MANUAL" do
      expect(described_class::MANUAL).to eq("manual")
    end

    it "defines UNKNOWN_LEGACY" do
      expect(described_class::UNKNOWN_LEGACY).to eq("unknown_legacy")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "self_rated",
          "year_end_computer",
          "early_start_bump",
          "mid_year_bump",
          "three_strike_dq",
          "appeal_granted",
          "appeal_denied",
          "manual",
          "unknown_legacy"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::SELF_RATED).to be_frozen
      expect(described_class::YEAR_END_COMPUTER).to be_frozen
      expect(described_class::EARLY_START_BUMP).to be_frozen
      expect(described_class::MID_YEAR_BUMP).to be_frozen
      expect(described_class::THREE_STRIKE_DQ).to be_frozen
      expect(described_class::APPEAL_GRANTED).to be_frozen
      expect(described_class::APPEAL_DENIED).to be_frozen
      expect(described_class::MANUAL).to be_frozen
      expect(described_class::UNKNOWN_LEGACY).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Self Rated", "self_rated" ],
          [ "Year End Computer", "year_end_computer" ],
          [ "Early Start Bump", "early_start_bump" ],
          [ "Mid Year Bump", "mid_year_bump" ],
          [ "Three Strike Dq", "three_strike_dq" ],
          [ "Appeal Granted", "appeal_granted" ],
          [ "Appeal Denied", "appeal_denied" ],
          [ "Manual", "manual" ],
          [ "Unknown Legacy", "unknown_legacy" ]
        ]
      )
    end
  end
end
