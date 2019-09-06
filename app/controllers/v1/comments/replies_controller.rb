# frozen_string_literal: true

class V1::Comments::RepliesController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Comment.find_by(id: params[:comment_id])
  end

  def comment_params
    params.require(:reply)
      .permit(:body)
      .merge(commenter: @current_user)
  end

  def build_comment
    @commentable.replies.build(comment_params)
  end
end
