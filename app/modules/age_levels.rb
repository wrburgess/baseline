module AgeLevels
  AGE_18_PLUS = "18_plus".freeze
  AGE_40_PLUS = "40_plus".freeze
  AGE_55_PLUS = "55_plus".freeze
  AGE_65_PLUS = "65_plus".freeze
  AGE_70_PLUS = "70_plus".freeze

  def self.all
    [
      AGE_18_PLUS,
      AGE_40_PLUS,
      AGE_55_PLUS,
      AGE_65_PLUS,
      AGE_70_PLUS
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
