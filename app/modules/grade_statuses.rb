module GradeStatuses
  ACTIVE = "active".freeze
  APPEALED = "appealed".freeze
  DQ = "dq".freeze
  MANUAL = "manual".freeze

  def self.all
    [
      ACTIVE,
      APPEALED,
      DQ,
      MANUAL
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
