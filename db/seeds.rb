ryto = User.create(
  email: 'ryto@gmail.com',
  username: 'ryto',
  password: 'password',
  first_name: 'Ryto',
  last_name: 'Verkar'
)

mike = User.create(
  email: 'mike@gmail.com',
  username: 'mike',
  password: 'password',
  first_name: 'Mike',
  last_name: 'Jordan'
)

anna = User.create(
  email: 'anna@gmail.com',
  username: 'anna',
  password: 'password',
  first_name: 'Anna',
  last_name: 'Banana'
)

george = User.create(
  email: 'george@gmail.com',
  username: 'george',
  password: 'password',
  first_name: 'George',
  last_name: 'Washington'
)

ryto.active_friendships.create(passive_friend: anna, confirmed: true)
mike.active_friendships.create(passive_friend: ryto, confirmed: true)
anna.active_friendships.create(passive_friend: mike)
george.active_friendships.create(passive_friend: anna)

50.times do |n|
  User.create(
    email: "user#{n}@gmail.com",
    username: "user#{n}",
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
  )
end

9.times do |n|
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n+1}"), confirmed: true)
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n+11}"), confirmed: true)
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n+31}"))
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n+21}"))
end

9.times do |n|
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n+1}"), confirmed: true)
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n+21}"), confirmed: true)
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n+11}"))
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n+41}"))
end

5.times do |n|
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n+41}"), confirmed: true)
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n+11}"), confirmed: true)
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n+21}"))
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n+31}"))
end

5.times do |n|
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n+11}"), confirmed: true)
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n+1}"), confirmed: true)
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n+31}"))
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n+21}"))
end