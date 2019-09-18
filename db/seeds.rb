# frozen_string_literal: true
include Rails.application.routes.url_helpers

def pic_url(pic)
  rails_blob_path(pic, only_path: true)
end

def add_profile_and_cover_pic(user)
  user.update(
    profile_pic: pic_url(user.profile_images.first),
    cover_pic: pic_url(user.cover_images.first)
  )
end

ryto = FactoryBot.create(
  :user,
  :male,
  :with_male_profile_images,
  :with_icy_cover_images,
  first_name: 'Ryto',
  last_name: 'Verkar',
)

mike = FactoryBot.create(
  :user,
  :male,
  :with_male_profile_images,
  :with_blue_cover_images,
  first_name: 'Mike',
  last_name: 'Jordan'
)

anna = FactoryBot.create(
  :user,
  :female,
  :with_female_profile_images,
  :with_icy_cover_images,
  first_name: 'Anna',
  last_name: 'Banana'
)

george = FactoryBot.create(
  :user,
  :male,
  :with_male_profile_images,
  :with_blue_cover_images,
  first_name: 'George',
  last_name: 'Washington'
)

add_profile_and_cover_pic(ryto)
add_profile_and_cover_pic(mike)
add_profile_and_cover_pic(anna)
add_profile_and_cover_pic(george)

FactoryBot.create(:friendship, active_friend: ryto, passive_friend: anna, confirmed: true)
FactoryBot.create(:friendship, active_friend: mike, passive_friend: ryto, confirmed: true)
FactoryBot.create(:friendship, active_friend: anna, passive_friend: mike)
FactoryBot.create(:friendship, active_friend: george, passive_friend: anna)

8.times do |_n|
  FactoryBot.create(
    :user,
    :male,
    username: FactoryBot.generate(:username)
  )
end

8.times do |n|
  FactoryBot.create(
    :user,
    :female,
    username: FactoryBot.generate(:username)
  )
end

4.times do |n|
  FactoryBot.create(:friendship, :confirmed, active_friend: ryto, passive_friend: User.find_by(username: "user#{n + 1}"))
  FactoryBot.create(:friendship, :confirmed, active_friend: User.find_by(username: "user#{n + 5}"), passive_friend: ryto)
  FactoryBot.create(:request, active_friend: ryto, passive_friend: User.find_by(username: "user#{n + 9}"))
  FactoryBot.create(:request, active_friend: User.find_by(username: "user#{n + 13}"), passive_friend: ryto)
end

4.times do |n|
  FactoryBot.create(:friendship, :confirmed, active_friend: mike, passive_friend: User.find_by(username: "user#{n + 5}"))
  FactoryBot.create(:friendship, :confirmed, active_friend: User.find_by(username: "user#{n + 1}"), passive_friend: mike)
  FactoryBot.create(:request, active_friend: mike, passive_friend: User.find_by(username: "user#{n + 13}"))
  FactoryBot.create(:request, active_friend: User.find_by(username: "user#{n + 9}"), passive_friend: mike)
end

4.times do |n|
  FactoryBot.create(:friendship, :confirmed, active_friend: anna, passive_friend: User.find_by(username: "user#{n + 9}"))
  FactoryBot.create(:friendship, :confirmed, active_friend: User.find_by(username: "user#{n + 13}"), passive_friend: anna)
  FactoryBot.create(:request, active_friend: anna, passive_friend: User.find_by(username: "user#{n + 1}"))
  FactoryBot.create(:request, active_friend: User.find_by(username: "user#{n + 5}"), passive_friend: anna)
end

4.times do |n|
  FactoryBot.create(:friendship, :confirmed, active_friend: george, passive_friend: User.find_by(username: "user#{n + 13}"))
  FactoryBot.create(:friendship, :confirmed, active_friend: User.find_by(username: "user#{n + 9}"), passive_friend: george)
  FactoryBot.create(:request, active_friend: george, passive_friend: User.find_by(username: "user#{n + 5}"))
  FactoryBot.create(:request, active_friend: User.find_by(username: "user#{n + 1}"), passive_friend: george)
end

# Set authored and received posts for ryto
5.times do |n|
  FactoryBot.create(
    :post,
    :with_pics,
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

# Set comments on ryto's authored posts
ryto.authored_posts.each_with_index do |post, index|
  comment = FactoryBot.create(
    :comment,
    :for_post,
    commentable: post,
    commenter: post.postable
  )
  reply = FactoryBot.create(
    :reply,
    :for_comment,
    commentable: comment,
    commenter: ryto.friends[index]
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
    :with_pics,
    author: mike.friends[n + 4],
    postable: mike
  )
end

# Set comments on mike's received posts
mike.received_posts.each_with_index do |post, index|
  comment = FactoryBot.create(
    :comment,
    :for_post,
    commentable: post,
    commenter: mike
  )

  reply = FactoryBot.create(
    :reply,
    :for_comment,
    commentable: comment,
    commenter: mike.friends[index]
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

# Seed likes in first 20 posts
Post.limit(20).each do |post|
  FactoryBot.create(
    :like,
    :for_post,
    likeable: post,
    liker: post.postable
  )
end

# See likes in first 20 comments
Comment.all.each do |comment|
  if comment.commentable_type == 'Post'
    FactoryBot.create(
      :like,
      :for_comment,
      likeable: comment,
      liker: comment.commentable.author
    )
  else
    FactoryBot.create(
      :like,
      :for_reply,
      likeable: comment,
      liker: comment.commentable.commenter
    )
  end
end