# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "user#{n}@gmail.com"
  end
end

FactoryBot.define do
  sequence :username do |n|
    "user#{n}"
  end
end
