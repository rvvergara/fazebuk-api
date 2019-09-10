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
  end
end
