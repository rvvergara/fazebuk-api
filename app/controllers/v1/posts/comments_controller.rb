# frozen_string_literal: true

class V1::Posts::CommentsController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    Post.find_by(id: params[:post_id])
  end

  def comment_params
    params.require(:comment)
      .permit(:body)
      .merge(commenter: pundit_user)
  end

  def build_comment
    set_commentable.comments.build(comment_params)
  end
end
