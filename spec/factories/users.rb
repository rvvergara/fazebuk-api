# frozen_string_literal: true

FactoryBot.define do
  factory :male_user, class: 'User' do
    email { Faker::Internet.email }
    password { 'password' }
    first_name { Faker::Name.male_first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Lorem.sentence(word_count: 1) }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    gender { 'male' }
  end

  factory :female_user, class: 'User' do
    email { Faker::Internet.email }
    password { 'password' }
    first_name { Faker::Name.female_first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Lorem.sentence(word_count: 1) }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    gender { 'female' }
  end
end
