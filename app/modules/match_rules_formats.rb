module MatchRulesFormats
  BEST_OF_3_STANDARD = "best_of_3_standard".freeze
  BEST_OF_3_MATCH_TB = "best_of_3_match_tb".freeze
  FAST4 = "fast4".freeze
  PRO_SET_8 = "pro_set_8".freeze
  PRO_SET_10 = "pro_set_10".freeze
  MATCH_TB_10 = "match_tb_10".freeze
  MATCH_TB_7 = "match_tb_7".freeze
  CUSTOM = "custom".freeze

  def self.all
    [
      BEST_OF_3_STANDARD,
      BEST_OF_3_MATCH_TB,
      FAST4,
      PRO_SET_8,
      PRO_SET_10,
      MATCH_TB_10,
      MATCH_TB_7,
      CUSTOM
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
