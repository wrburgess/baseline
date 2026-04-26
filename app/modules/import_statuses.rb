module ImportStatuses
  UPLOADED = "uploaded".freeze
  PARSING = "parsing".freeze
  NEEDS_REVIEW = "needs_review".freeze
  COMMITTED = "committed".freeze
  FAILED = "failed".freeze

  def self.all
    [
      UPLOADED,
      PARSING,
      NEEDS_REVIEW,
      COMMITTED,
      FAILED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
