module ImportKinds
  TEAM_ROSTER = "team_roster".freeze
  MATCH_NIGHT = "match_night".freeze
  PLAYER_RATINGS = "player_ratings".freeze
  LEAGUE_SCHEDULE = "league_schedule".freeze

  def self.all
    [
      TEAM_ROSTER,
      MATCH_NIGHT,
      PLAYER_RATINGS,
      LEAGUE_SCHEDULE
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
