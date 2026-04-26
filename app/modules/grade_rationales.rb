module GradeRationales
  SELF_RATED = "self_rated".freeze
  YEAR_END_COMPUTER = "year_end_computer".freeze
  EARLY_START_BUMP = "early_start_bump".freeze
  MID_YEAR_BUMP = "mid_year_bump".freeze
  THREE_STRIKE_DQ = "three_strike_dq".freeze
  APPEAL_GRANTED = "appeal_granted".freeze
  APPEAL_DENIED = "appeal_denied".freeze
  MANUAL = "manual".freeze
  UNKNOWN_LEGACY = "unknown_legacy".freeze

  def self.all
    [
      SELF_RATED,
      YEAR_END_COMPUTER,
      EARLY_START_BUMP,
      MID_YEAR_BUMP,
      THREE_STRIKE_DQ,
      APPEAL_GRANTED,
      APPEAL_DENIED,
      MANUAL,
      UNKNOWN_LEGACY
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
