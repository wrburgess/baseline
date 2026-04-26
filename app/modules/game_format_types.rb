module GameFormatTypes
  LEVEL = "level".freeze
  TRI_LEVEL = "tri_level".freeze
  MIXED_DOUBLES = "mixed_doubles".freeze
  COMBO_DOUBLES = "combo_doubles".freeze
  SINGLES_ONLY = "singles_only".freeze

  def self.all
    [
      LEVEL,
      TRI_LEVEL,
      MIXED_DOUBLES,
      COMBO_DOUBLES,
      SINGLES_ONLY
    ]
  end

  def self.options_for_select
    all.map { |item| [ item.titleize, item ] }
  end
end
