require "rails_helper"

RSpec.describe PlayerGenders do
  describe "constants" do
    it "defines MALE" do
      expect(described_class::MALE).to eq("male")
    end

    it "defines FEMALE" do
      expect(described_class::FEMALE).to eq("female")
    end

    it "defines NONBINARY" do
      expect(described_class::NONBINARY).to eq("nonbinary")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "male",
          "female",
          "nonbinary"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::MALE).to be_frozen
      expect(described_class::FEMALE).to be_frozen
      expect(described_class::NONBINARY).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Male", "male" ],
          [ "Female", "female" ],
          [ "Nonbinary", "nonbinary" ]
        ]
      )
    end
  end
end
