# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :author, factory: :user
    association :postable, factory: :user
    content { Faker::Lorem.paragraph(sentence_count: 3) }

    trait :invalid do
      content { nil }
    end

    trait :with_pics do
      pics do
        Rack::Test::UploadedFile.new(Rails.root + 'spec/support/assets/icy-lake.jpg', 'image/jpg')
      end
    end
  end
end
