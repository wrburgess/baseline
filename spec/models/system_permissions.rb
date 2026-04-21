FactoryBot.define do
  factory :system_permission do
    name { Faker::Lorem.word }
    abbreviation { Faker::Lorem.word }
    resource { Faker::Lorem.word }
    operation { Faker::Lorem.word }
    description { Faker::Lorem.sentence(word_count: 6) }
    notes { Faker::Lorem.sentence(word_count: 4) }
  end
end
