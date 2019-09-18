# frozen_string_literal: true

class V1::Comments::LikesController < V1::LikesController
  before_action :set_likeable

  private

  def set_likeable
    comment = Comment.find_by(id: params[:comment_id])
    return comment if comment

    find_error('comment')
    nil
  end
end
