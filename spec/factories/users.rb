# frozen_string_literal: true

FactoryBot.define do
  factory :user,
          aliases: %i[author commenter liker postable active_friend passive_friend] do
    trait :male do
      gender { 'male' }
      first_name { Faker::Name.male_first_name }
    end

    trait :female do
      gender { 'female' }
      first_name { Faker::Name.female_first_name }
    end

    trait :invalid do
      username { first_name }
    end

    trait :with_male_profile_images do
      profile_images do
        Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/assets/male.jpg", 'image/jpg')
      end
    end

    trait :with_female_profile_images do
      profile_images do
        Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/assets/female.png", 'image/png')
      end
    end

    trait :with_icy_cover_images do
      cover_images do
        Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/assets/icy-lake.jpg", 'image/jpg')
      end
    end

    trait :with_blue_cover_images do
      cover_images do
        Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/assets/blue-red-lake.jpg", 'image/jpg')
      end
    end

    last_name { Faker::Name.last_name }
    username { first_name.downcase }
    email { "#{username}@gmail.com" }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    password { 'password' }
  end
end
