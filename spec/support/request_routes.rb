# frozen_string_literal: true

module Helpers
  module RequestRoutes
    # User route
    def user_route(username = nil)
      "/v1/users/#{username}"
    end

    # Post routes
    def posts_route
      '/v1/posts'
    end

    def post_route(post_id)
      "/v1/posts/#{post_id}"
    end

    # Comment and replies routes
    def post_comments_route(post_id)
      "/v1/posts/#{post_id}/comments"
    end

    def comment_replies_route(comment_id)
      "/v1/comments/#{comment_id}/replies"
    end

    def comment_route(comment_id)
      "/v1/comments/#{comment_id}"
    end

    # Like routes
    def post_likes_route(post_id)
      "/v1/posts/#{post_id}/likes"
    end

    def comment_likes_route(comment_id)
      "/v1/comments/#{comment_id}/likes"
    end

    def like_route(like_id)
      "/v1/likes/#{like_id}"
    end
  end
end
