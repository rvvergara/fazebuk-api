# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    body { 'MyText' }
    commentable_id { '' }
    author_id { '' }
    commentable_type { 'MyString' }
  end
end
