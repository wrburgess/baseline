module GenderTypes
  MEN = "men".freeze
  WOMEN = "women".freeze
  MIXED = "mixed".freeze

  def self.all
    [
      MEN,
      WOMEN,
      MIXED
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
