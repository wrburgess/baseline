require "rails_helper"

RSpec.describe AliasSources do
  describe "constants" do
    it "defines CAPTAIN_ENTERED" do
      expect(described_class::CAPTAIN_ENTERED).to eq("captain_entered")
    end

    it "defines PARSER_OBSERVED" do
      expect(described_class::PARSER_OBSERVED).to eq("parser_observed")
    end

    it "defines IMPORTED" do
      expect(described_class::IMPORTED).to eq("imported")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "captain_entered",
          "parser_observed",
          "imported"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::CAPTAIN_ENTERED).to be_frozen
      expect(described_class::PARSER_OBSERVED).to be_frozen
      expect(described_class::IMPORTED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Captain Entered", "captain_entered" ],
          [ "Parser Observed", "parser_observed" ],
          [ "Imported", "imported" ]
        ]
      )
    end
  end
end
