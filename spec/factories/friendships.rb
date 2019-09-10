# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    active_friend
    passive_friend
  end
end
