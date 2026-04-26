require "rails_helper"

RSpec.describe GradeStatuses do
  describe "constants" do
    it "defines ACTIVE" do
      expect(described_class::ACTIVE).to eq("active")
    end

    it "defines APPEALED" do
      expect(described_class::APPEALED).to eq("appealed")
    end

    it "defines DQ" do
      expect(described_class::DQ).to eq("dq")
    end

    it "defines MANUAL" do
      expect(described_class::MANUAL).to eq("manual")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "active",
          "appealed",
          "dq",
          "manual"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::ACTIVE).to be_frozen
      expect(described_class::APPEALED).to be_frozen
      expect(described_class::DQ).to be_frozen
      expect(described_class::MANUAL).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Active", "active" ],
          [ "Appealed", "appealed" ],
          [ "Dq", "dq" ],
          [ "Manual", "manual" ]
        ]
      )
    end
  end
end
