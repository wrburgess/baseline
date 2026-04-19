FactoryBot.define do
  factory :system_permission do
    sequence(:name) { |n| "Permission #{n}" }
    sequence(:abbreviation) { |n| "P#{n.to_s.rjust(3, "0")}" }
    description { "Grants access to a specific action." }
    notes { "Automatically generated in test factory." }
    sequence(:resource) { |n| "resource_#{n}" }
    sequence(:operation) { |n| "operation_#{n}" }
  end
end
