# frozen_string_literal: true

class V1::Comments::RepliesController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    Comment.find_by(id: params[:comment_id])
  end

  def comment_params
    params.require(:reply)
      .permit(:body)
      .merge(commenter: pundit_user)
  end

  def build_comment
    if set_commentable
      set_commentable.replies.build(comment_params)
    else
      render json: { message: 'Cannot find comment' }, status: 404
      nil
    end
  end
end
