FactoryBot.define do
  factory :category do
    name { Faker::Color.name }
  end
end
