module AliasSources
  CAPTAIN_ENTERED = "captain_entered".freeze
  PARSER_OBSERVED = "parser_observed".freeze
  IMPORTED = "imported".freeze

  def self.all
    [
      CAPTAIN_ENTERED,
      PARSER_OBSERVED,
      IMPORTED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
