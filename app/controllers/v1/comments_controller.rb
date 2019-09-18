# frozen_string_literal: true

class V1::CommentsController < ApplicationController
  before_action :pundit_user

  def create
    comment = build_comment
    return unless comment

    comment.adding_or_purging_pic = true if comment_params[:pic]
    if comment.save
      render :create, locals: { comment: comment }, status: :created
    else
      render json: { message: 'Cannot create comment', errors: comment.errors }, status: :unprocessable_entity
    end
  end

  def update
    comment = set_comment
    return unless comment

    if comment.update(update_params)
      render :update, locals: { comment: comment }, status: :accepted
    else
      render json: { message: 'Cannot update comment', errors: comment.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = set_comment
    return unless comment

    comment.destroy

    action_success('Comment deleted')
  end

  private

  def build_comment
    return unless set_commentable

    if set_commentable.class == Post
      set_commentable.comments.build(comment_params)
    elsif set_commentable.class == Comment
      set_commentable.replies.build(comment_params)
    end
  end

  def update_params
    params.require(:comment).permit(:body, :pic).merge(commenter: pundit_user)
  end

  def set_comment
    comment = pundit_user.authored_comments.find_by(id: params[:id])

    return comment if comment

    find_error('comment')
    nil
  end
end
