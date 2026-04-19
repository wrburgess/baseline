FactoryBot.define do
  factory :system_group do
    sequence(:name) { |n| "Group #{n}" }
    sequence(:abbreviation) { |n| "G#{n.to_s.rjust(3, "0")}" }
    description { "Group generated for testing." }
    notes { "Automatically created by the factory." }
  end
end
