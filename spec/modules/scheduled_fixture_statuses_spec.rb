require "rails_helper"

RSpec.describe ScheduledFixtureStatuses do
  describe "constants" do
    it "defines SCHEDULED" do
      expect(described_class::SCHEDULED).to eq("scheduled")
    end

    it "defines COMPLETED" do
      expect(described_class::COMPLETED).to eq("completed")
    end

    it "defines POSTPONED" do
      expect(described_class::POSTPONED).to eq("postponed")
    end

    it "defines CANCELLED" do
      expect(described_class::CANCELLED).to eq("cancelled")
    end

    it "defines DEFAULTED" do
      expect(described_class::DEFAULTED).to eq("defaulted")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "scheduled",
          "completed",
          "postponed",
          "cancelled",
          "defaulted"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::SCHEDULED).to be_frozen
      expect(described_class::COMPLETED).to be_frozen
      expect(described_class::POSTPONED).to be_frozen
      expect(described_class::CANCELLED).to be_frozen
      expect(described_class::DEFAULTED).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Scheduled", "scheduled" ],
          [ "Completed", "completed" ],
          [ "Postponed", "postponed" ],
          [ "Cancelled", "cancelled" ],
          [ "Defaulted", "defaulted" ]
        ]
      )
    end
  end
end
