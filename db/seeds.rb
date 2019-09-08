ryto = User.create(
  email: 'ryto@gmail.com',
  username: 'ryto',
  password: 'password',
  first_name: 'Ryto',
  last_name: 'Verkar',
  birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: 'male',
  bio: Faker::Lorem.paragraph(sentence_count: 3)
)

mike = User.create(
  email: 'mike@gmail.com',
  username: 'mike',
  password: 'password',
  first_name: 'Mike',
  last_name: 'Jordan',
  birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: 'male',
  bio: Faker::Lorem.paragraph(sentence_count: 3)
)

anna = User.create(
  email: 'anna@gmail.com',
  username: 'anna',
  password: 'password',
  first_name: 'Anna',
  last_name: 'Banana',
  birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: 'female',
  bio: Faker::Lorem.paragraph(sentence_count: 3)
)

george = User.create(
  email: 'george@gmail.com',
  username: 'george',
  password: 'password',
  first_name: 'George',
  last_name: 'Washington',
  birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
  gender: 'male',
  bio: Faker::Lorem.paragraph(sentence_count: 3)
)

ryto.active_friendships.create(passive_friend: anna, confirmed: true)
mike.active_friendships.create(passive_friend: ryto, confirmed: true)
anna.active_friendships.create(passive_friend: mike)
george.active_friendships.create(passive_friend: anna)

8.times do |n|
  User.create(
    email: "user#{n+1}@gmail.com",
    username: "user#{n+1}",
    password: 'password',
    first_name: Faker::Name.male_first_name,
    last_name: Faker::Name.last_name,
    birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
    gender: 'male',
    bio: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

8.times do |n|
  User.create(
    email: "user#{n+9}@gmail.com",
    username: "user#{n+9}",
    password: 'password',
    first_name: Faker::Name.female_first_name,
    last_name: Faker::Name.last_name,
    birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
    gender: 'female',
    bio: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

4.times do |n|
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n+1}"), confirmed: true)
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n+5}"), confirmed: true)
  ryto.active_friendships.create(passive_friend: User.find_by(username: "user#{n+9}"))
  ryto.passive_friendships.create(active_friend: User.find_by(username: "user#{n+13}"))
end

4.times do |n|
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n+5}"), confirmed: true)
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n+1}"), confirmed: true)
  mike.active_friendships.create(passive_friend: User.find_by(username: "user#{n+13}"))
  mike.passive_friendships.create(active_friend: User.find_by(username: "user#{n+9}"))
end

4.times do |n|
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n+9}"), confirmed: true)
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n+13}"), confirmed: true)
  anna.active_friendships.create(passive_friend: User.find_by(username: "user#{n+1}"))
  anna.passive_friendships.create(active_friend: User.find_by(username: "user#{n+5}"))
end

4.times do |n|
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n+13}"), confirmed: true)
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n+9}"), confirmed: true)
  george.active_friendships.create(passive_friend: User.find_by(username: "user#{n+5}"))
  george.passive_friendships.create(active_friend: User.find_by(username: "user#{n+1}"))
end

# Set authored and received posts for ryto
5.times do |n|
  ryto.authored_posts.create(
    postable: ryto.friends[n],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

5.times do |n|
  ryto.received_posts.create(
    author: ryto.friends[n+5],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# Set authored and received posts for mike
5.times do |n|
  mike.authored_posts.create(
    postable: mike.friends[n],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

4.times do |n|
  mike.received_posts.create(
    author: mike.friends[n+5],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# Set authored and received posts for anna
5.times do |n|
  anna.authored_posts.create(
    postable: anna.friends[n],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

4.times do |n|
  anna.received_posts.create(
    author: anna.friends[n+5],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# Set authored and received posts for george
4.times do |n|
  george.authored_posts.create(
    postable: george.friends[n],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

4.times do |n|
  george.received_posts.create(
    author: george.friends[n+5],
    content: Faker::Lorem.paragraph(sentence_count: 3)
  )
end

# Set authored and received posts for other users
User.where('username NOT IN (?)', ['ryto', 'mike', 'anna', 'george']).each do |user|
  user.authored_posts.create(postable: user.friends[0], content: Faker::Lorem.paragraph(sentence_count: 3))
  user.received_posts.create(author: user.friends[1], content: Faker::Lorem.paragraph(sentence_count: 3))
end