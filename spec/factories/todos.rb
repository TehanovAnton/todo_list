# frozen_string_literal: true

FactoryBot.define do
  factory :todo do
    title { Faker::Games::SuperMario.game }
    description { Faker::Games::SuperMario.character }
    due_date { Date.current + 1.day }

    trait :with_categories do
      categories { create_list(:category, 2) }
    end
  end
end
