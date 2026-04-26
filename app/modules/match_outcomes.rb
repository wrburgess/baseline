module MatchOutcomes
  COMPLETED = "completed".freeze
  RETIRED = "retired".freeze
  DEFAULTED = "defaulted".freeze
  WALKOVER = "walkover".freeze
  TIMED = "timed".freeze

  def self.all
    [
      COMPLETED,
      RETIRED,
      DEFAULTED,
      WALKOVER,
      TIMED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
