# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    liker_id { '' }
    likeable_type { 'MyString' }
    likeable_id { '' }
  end
end
