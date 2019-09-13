# frozen_string_literal: true

FactoryBot.define do
  factory :friendship, aliases: [:request] do
    active_friend
    passive_friend

    trait :confirmed do
      confirmed { true }
    end
  end
end
