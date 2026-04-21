FactoryBot.define do
  factory :system_role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:abbreviation) { |n| "R#{n.to_s.rjust(3, "0")}" }
    description { "Role generated for testing." }
    notes { "Automatically created by the factory." }
  end
end
