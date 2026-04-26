module GradeSources
  MANUAL = "manual".freeze
  PARSER_TENNISRECORD = "parser_tennisrecord".freeze
  PARSER_WTN = "parser_wtn".freeze
  PARSER_TENNISLINK = "parser_tennislink".freeze
  IMPORTED = "imported".freeze

  def self.all
    [
      MANUAL,
      PARSER_TENNISRECORD,
      PARSER_WTN,
      PARSER_TENNISLINK,
      IMPORTED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
