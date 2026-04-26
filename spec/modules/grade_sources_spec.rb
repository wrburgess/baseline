require "rails_helper"

RSpec.describe GradeSources do
  describe "constants" do
    it "defines MANUAL" do
      expect(described_class::MANUAL).to eq("manual")
    end

    it "defines PARSER_TENNISRECORD" do
      expect(described_class::PARSER_TENNISRECORD).to eq("parser_tennisrecord")
    end

    it "defines PARSER_WTN" do
      expect(described_class::PARSER_WTN).to eq("parser_wtn")
    end

    it "defines PARSER_TENNISLINK" do
      expect(described_class::PARSER_TENNISLINK).to eq("parser_tennislink")
    end

    it "defines IMPORTED" do
      expect(described_class::IMPORTED).to eq("imported")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "manual",
          "parser_tennisrecord",
          "parser_wtn",
          "parser_tennislink",
          "imported"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::MANUAL).to be_frozen
      expect(described_class::PARSER_TENNISRECORD).to be_frozen
      expect(described_class::PARSER_WTN).to be_frozen
      expect(described_class::PARSER_TENNISLINK).to be_frozen
      expect(described_class::IMPORTED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Manual", "manual" ],
          [ "Parser Tennisrecord", "parser_tennisrecord" ],
          [ "Parser Wtn", "parser_wtn" ],
          [ "Parser Tennislink", "parser_tennislink" ],
          [ "Imported", "imported" ]
        ]
      )
    end
  end
end
