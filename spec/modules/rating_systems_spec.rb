require "rails_helper"

RSpec.describe RatingSystems do
  describe "constants" do
    it "defines USTA_NTRP" do
      expect(described_class::USTA_NTRP).to eq("usta_ntrp")
    end

    it "defines TENNIS_RECORD" do
      expect(described_class::TENNIS_RECORD).to eq("tennis_record")
    end

    it "defines WTN_DYNAMIC" do
      expect(described_class::WTN_DYNAMIC).to eq("wtn_dynamic")
    end

    it "defines WTN_SINGLES" do
      expect(described_class::WTN_SINGLES).to eq("wtn_singles")
    end

    it "defines UTR_DYNAMIC" do
      expect(described_class::UTR_DYNAMIC).to eq("utr_dynamic")
    end

    it "defines UTR_SINGLES" do
      expect(described_class::UTR_SINGLES).to eq("utr_singles")
    end

    it "defines UTR_DOUBLES" do
      expect(described_class::UTR_DOUBLES).to eq("utr_doubles")
    end
  end

  describe ".all" do
    it "returns all values in canonical order" do
      expect(described_class.all).to eq(
        [
          "usta_ntrp",
          "tennis_record",
          "wtn_dynamic",
          "wtn_singles",
          "utr_dynamic",
          "utr_singles",
          "utr_doubles"
        ]
      )
    end

    it "is frozen to prevent modification" do
      expect(described_class::USTA_NTRP).to be_frozen
      expect(described_class::TENNIS_RECORD).to be_frozen
      expect(described_class::WTN_DYNAMIC).to be_frozen
      expect(described_class::WTN_SINGLES).to be_frozen
      expect(described_class::UTR_DYNAMIC).to be_frozen
      expect(described_class::UTR_SINGLES).to be_frozen
      expect(described_class::UTR_DOUBLES).to be_frozen
    end
  end

  describe ".options_for_select" do
    it "returns an array of label/value pairs for form selects" do
      expect(described_class.options_for_select).to eq(
        [
          [ "Usta Ntrp", "usta_ntrp" ],
          [ "Tennis Record", "tennis_record" ],
          [ "Wtn Dynamic", "wtn_dynamic" ],
          [ "Wtn Singles", "wtn_singles" ],
          [ "Utr Dynamic", "utr_dynamic" ],
          [ "Utr Singles", "utr_singles" ],
          [ "Utr Doubles", "utr_doubles" ]
        ]
      )
    end
  end
end
