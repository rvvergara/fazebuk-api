# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :author, factory: :user
    association :postable, factory: :user
    content { Faker::Lorem.paragraph(sentence_count: 3) }
  end
end
