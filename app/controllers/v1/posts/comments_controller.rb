# frozen_string_literal: true

class V1::Posts::CommentsController < V1::CommentsController
  before_action :set_commentable

  private

  def set_commentable
    post = Post.find_by(id: params[:post_id])
    return post if post

    find_error('post')
    nil
  end

  def comment_params
    params.require(:comment)
      .permit(:body, :pic)
      .merge(commenter: pundit_user)
  end
end
