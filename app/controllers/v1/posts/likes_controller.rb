# frozen_string_literal: true

class V1::Posts::LikesController < V1::LikesController
  before_action :set_likeable

  private

  def set_likeable
    Post.find_by(id: params[:post_id])
  end

  def build_like
    pundit_user.likes.build(likeable: set_likeable)
  end
end
