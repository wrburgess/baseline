module TeamMatchLevels
  REGULAR_SEASON = "regular_season".freeze
  LOCAL_PLAYOFF = "local_playoff".freeze
  DISTRICT = "district".freeze
  SECTION = "section".freeze
  NATIONAL = "national".freeze
  TOURNAMENT = "tournament".freeze

  def self.all
    [
      REGULAR_SEASON,
      LOCAL_PLAYOFF,
      DISTRICT,
      SECTION,
      NATIONAL,
      TOURNAMENT
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
