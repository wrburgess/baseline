module RatingSystems
  USTA_NTRP = "usta_ntrp".freeze
  TENNIS_RECORD = "tennis_record".freeze
  WTN_DYNAMIC = "wtn_dynamic".freeze
  WTN_SINGLES = "wtn_singles".freeze
  UTR_DYNAMIC = "utr_dynamic".freeze
  UTR_SINGLES = "utr_singles".freeze
  UTR_DOUBLES = "utr_doubles".freeze

  def self.all
    [
      USTA_NTRP,
      TENNIS_RECORD,
      WTN_DYNAMIC,
      WTN_SINGLES,
      UTR_DYNAMIC,
      UTR_SINGLES,
      UTR_DOUBLES
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
