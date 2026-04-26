module MatchFormats
  SINGLES = "singles".freeze
  DOUBLES = "doubles".freeze

  def self.all
    [
      SINGLES,
      DOUBLES
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
