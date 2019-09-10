# frozen_string_literal: true

json.id comment.id
json.commenter do
  json.partial! '/v1/shared/user_short', user: comment.commenter
end
json.body comment.body
json.created_at convert_to_i(comment.created_at)
json.updated_at convert_to_i(comment.updated_at)
if comment.commentable_type == 'Post'
  json.replies do
    json.count comment.replies.count
    json.list do
      json.array! comment.replies do |reply|
        json.partial! '/v1/shared/comment', comment: reply
      end
    end
  end
end
json.likes do
  json.count comment.likes.count
  json.likers do
    json.array! comment.likes do |like|
      json.partial! '/v1/shared/user_short', user: like.liker
    end
  end
end
json.liked? pundit_user.liked?(comment)
json.like_id comment.like_id(pundit_user)
