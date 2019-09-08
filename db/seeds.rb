# frozen_string_literal: true

ryto = FactoryBot.create(
  :male_user,
  email: 'ryto@gmail.com',
  username: 'ryto',
  first_name: 'Ryto',
  last_name: 'Verkar'
)

mike = FactoryBot.create(
  :male_user,
  email: 'mike@gmail.com',
  username: 'mike',
  first_name: 'Mike',
  last_name: 'Jordan'
)

anna = FactoryBot.create(
  :female_user,
  email: 'anna@gmail.com',
  username: 'anna',
  first_name: 'Anna',
  last_name: 'Banana'
)

george = FactoryBot.create(
  :male_user,
  email: 'george@gmail.com',
  username: 'george',
  first_name: 'George',
  last_name: 'Washington'
)

FactoryBot.create(:friendship, active_friend: ryto, passive_friend: anna, confirmed: true)
FactoryBot.create(:friendship, active_friend: mike, passive_friend: ryto, confirmed: true)
FactoryBot.create(:friendship, active_friend: anna, passive_friend: mike)
FactoryBot.create(:friendship, active_friend: george, passive_friend: anna)

8.times do |_n|
  FactoryBot.create(
    :male_user,
    username: FactoryBot.generate(:username), email: FactoryBot.generate(:email)
  )
end

8.times do |n|
  FactoryBot.create(
    :male_user,
    username: FactoryBot.generate(:username), email: FactoryBot.generate(:email)
  )
end

4.times do |n|
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 1}"), confirmed: true)
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 5}"), confirmed: true)
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 9}"))
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 13}"))
end

4.times do |n|
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 5}"), confirmed: true)
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 1}"), confirmed: true)
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 13}"))
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 9}"))
end

4.times do |n|
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 9}"), confirmed: true)
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 13}"), confirmed: true)
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 1}"))
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 5}"))
end

4.times do |n|
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 13}"), confirmed: true)
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 9}"), confirmed: true)
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n + 5}"))
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n + 1}"))
end

# Set authored and received posts for ryto
5.times do |n|
  FactoryBot.create(
    :post,
    author: ryto,
    postable: ryto.friends[n]
  )
end

5.times do |n|
  FactoryBot.create(
    :post,
    author: ryto.friends[n + 5],
    postable: ryto
  )
end

# Set authored and received posts for mike
5.times do |n|
  FactoryBot.create(
    :post,
    author: mike,
    postable: mike.friends[n]
  )
end

4.times do |n|
  FactoryBot.create(
    :post,
    author: mike.friends[n + 4],
    postable: mike
  )
end

# Set authored and received posts for anna
5.times do |n|
  FactoryBot.create(
    :post,
    author: anna,
    postable: anna.friends[n]
  )
end

4.times do |n|
  FactoryBot.create(
    :post,
    author: anna.friends[n + 4],
    postable: anna
  )
end

# Set authored and received posts for george
4.times do |n|
  FactoryBot.create(
    :post,
    author: george,
    postable: george.friends[n]
  )
end

4.times do |n|
  FactoryBot.create(
    :post,
    author: george.friends[n + 4],
    postable: george
  )
end

# Set authored and received posts for other users
User.where('username NOT IN (?)', %w[ryto mike anna george]).each do |user|
  FactoryBot.create(
    :post,
    author: user,
    postable: user.friends[0]
  )
  FactoryBot.create(
    :post,
    author: user.friends[1],
    postable: user
  )
end
