FactoryBot.define do
  factory :post do
    author_id { "" }
    user { nil }
    content { "MyText" }
  end
end
