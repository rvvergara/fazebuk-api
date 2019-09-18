# frozen_string_literal: true

module Helpers
  module PostAttributes
    def valid_post_attributes(postable, content_attr = {})
      attr = content_attr ? attributes_for(:post).merge(content_attr) : attributes_for(:post)
      {
        post: attr
          .merge(postable: postable.username)
      }
    end

    def invalid_post_attributes(postable)
      {
        post: attributes_for(:post, :invalid)
          .merge(postable: postable.username)
      }
    end
  end
end
