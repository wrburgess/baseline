module MatchSides
  HOME = "home".freeze
  AWAY = "away".freeze

  def self.all
    [
      HOME,
      AWAY
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
