# frozen_string_literal: true

class V1::Comments::LikesController < V1::LikesController
  before_action :set_likeable

  private

  def set_likeable
    Comment.find_by(id: params[:comment_id])
  end

  def build_like
    pundit_user.likes.build(likeable: set_likeable)
  end
end
