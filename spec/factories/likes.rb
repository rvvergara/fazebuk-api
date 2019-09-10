# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    trait :for_post do
      association(:likeable, factory: :post)
    end

    trait :for_post_comment do
      association(:likeable, factory: :post_comment)
    end

    trait :for_comment_reply do
      association(:likeable, factory: :comment_reply)
    end
  end
end
