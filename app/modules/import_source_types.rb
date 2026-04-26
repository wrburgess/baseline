module ImportSourceTypes
  TENNISLINK_TEAM_PAGE = "tennislink_team_page".freeze
  TENNISLINK_MATCH_RESULTS = "tennislink_match_results".freeze
  TENNISLINK_SCHEDULE_PAGE = "tennislink_schedule_page".freeze
  TENNISRECORD_PLAYER_PAGE = "tennisrecord_player_page".freeze
  WTN_PLAYER_PAGE = "wtn_player_page".freeze

  def self.all
    [
      TENNISLINK_TEAM_PAGE,
      TENNISLINK_MATCH_RESULTS,
      TENNISLINK_SCHEDULE_PAGE,
      TENNISRECORD_PLAYER_PAGE,
      WTN_PLAYER_PAGE
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
