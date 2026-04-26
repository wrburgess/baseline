module ScheduledFixtureStatuses
  SCHEDULED = "scheduled".freeze
  COMPLETED = "completed".freeze
  POSTPONED = "postponed".freeze
  CANCELLED = "cancelled".freeze
  DEFAULTED = "defaulted".freeze

  def self.all
    [
      SCHEDULED,
      COMPLETED,
      POSTPONED,
      CANCELLED,
      DEFAULTED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
