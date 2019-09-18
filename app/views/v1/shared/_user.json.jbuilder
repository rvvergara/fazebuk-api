# frozen_string_literal: true

json.bio user.bio
json.birthday user.birthday
json.cover_pic do
  json.partial! '/v1/shared/pic', pic: cover_pic(user) unless cover_pic(user).nil?
end
json.created_at user.created_at
json.email user.email
json.first_name user.first_name
json.gender user.gender
json.id user.id
json.last_name user.last_name
json.middle_name user.middle_name
json.profile_pic do
  json.partial! '/v1/shared/pic', pic: profile_pic(user) unless profile_pic(user).nil?
end
json.updated_at user.updated_at
json.username user.username
