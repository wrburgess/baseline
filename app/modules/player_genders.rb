module PlayerGenders
  MALE = "male".freeze
  FEMALE = "female".freeze
  NONBINARY = "nonbinary".freeze

  def self.all
    [
      MALE,
      FEMALE,
      NONBINARY
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
