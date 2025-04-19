FactoryBot.define do
  factory :todo do
    title { Faker::Games::SuperMario.game }
    description { Faker::Games::SuperMario.character }
    due_date { Date.current + 1.day }

    transient do
      categories { create_list(:category, 2) }
    end
  end
end
