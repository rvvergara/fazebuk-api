# frozen_string_literal: true

class V1::Posts::CommentsController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Post.find_by(id: params[:post_id])
  end
end
