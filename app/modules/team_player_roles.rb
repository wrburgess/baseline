module TeamPlayerRoles
  PLAYER = "player".freeze
  CO_CAPTAIN = "co_captain".freeze
  CAPTAIN = "captain".freeze

  def self.all
    [
      PLAYER,
      CO_CAPTAIN,
      CAPTAIN
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
