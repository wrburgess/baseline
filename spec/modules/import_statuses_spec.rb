require "rails_helper"

RSpec.describe ImportStatuses do
  describe "constants" do
    it "defines UPLOADED" do
      expect(described_class::UPLOADED).to eq("uploaded")
    end

    it "defines PARSING" do
      expect(described_class::PARSING).to eq("parsing")
    end

    it "defines NEEDS_REVIEW" do
      expect(described_class::NEEDS_REVIEW).to eq("needs_review")
    end

    it "defines COMMITTED" do
      expect(described_class::COMMITTED).to eq("committed")
    end

    it "defines FAILED" do
      expect(described_class::FAILED).to eq("failed")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "uploaded",
          "parsing",
          "needs_review",
          "committed",
          "failed"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::UPLOADED).to be_frozen
      expect(described_class::PARSING).to be_frozen
      expect(described_class::NEEDS_REVIEW).to be_frozen
      expect(described_class::COMMITTED).to be_frozen
      expect(described_class::FAILED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Uploaded", "uploaded" ],
          [ "Parsing", "parsing" ],
          [ "Needs Review", "needs_review" ],
          [ "Committed", "committed" ],
          [ "Failed", "failed" ]
        ]
      )
    end
  end
end
