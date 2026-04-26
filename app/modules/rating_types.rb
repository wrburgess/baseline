module RatingTypes
  S = "S".freeze
  C = "C".freeze
  A = "A".freeze
  M = "M".freeze

  def self.all
    [
      S,
      C,
      A,
      M
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
