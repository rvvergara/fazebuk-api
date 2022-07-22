# frozen_string_literal: true

FactoryBot.define do
  factory :comment, aliases: [:reply] do
    commenter
    body { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :for_post do
      association :commentable, factory: :post
      commentable_type { 'Post' }
    end

    trait :for_comment do
      association :commentable, factory: :comment
      commentable_type { 'Comment' }
    end

    trait :invalid do
      body { nil }
    end

    trait :with_pic do
      pic do
        Rack::Test::UploadedFile.new(Rails.root + 'spec/support/assets/icy-lake.jpg', 'image/jpg')
      end
    end
  end
end
