# frozen_string_literal: true

FactoryBot.define do
  factory :post_comment, class: 'Comment' do
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    association :commentable, factory: :post
    association :author, factory: :user
    commentable_type { 'Post' }
  end

  factory :comment_reply, class: 'Comment' do
    body { Faker::Lorem.paragraph(sentence_count: 2) }
    association :commentable, factory: :comment
    association :author, factory: :user
    commentable_type { 'Comment' }
  end
end
