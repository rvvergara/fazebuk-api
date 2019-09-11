# frozen_string_literal: true

class V1::Comments::RepliesController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    comment = Comment.find_by(id: params[:comment_id])
    return comment if comment

    render_error('comment')
    nil
  end

  def comment_params
    params.require(:reply)
      .permit(:body)
      .merge(commenter: pundit_user)
  end
end
