# frozen_string_literal: true

module Helpers
  module CommentAttributes
    # Comment and reply attributes
    def valid_comment_attributes(comment_type, attr = {})
      comment_attr = attr ? attributes_for(comment_type).merge(attr) : attributes_for(comment_type)
      { comment_type => comment_attr }
    end

    def invalid_comment_attributes(resource, trait, update_resource = nil)
      update_resource ||= resource

      {
        update_resource => attributes_for(resource, :invalid, trait)
      }
    end
  end
end
