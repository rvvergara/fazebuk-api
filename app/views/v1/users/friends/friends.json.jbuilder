# frozen_string_literal: true

json.friends_of @user.username
json.friends @friends do |friend|
  json.partial! 'v1/shared/user', user: friend
end
