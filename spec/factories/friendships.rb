# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    active_friend_id { '' }
    passive_friend_id { '' }
    status { false }
    combined_ids { 'MyString' }
  end
end
