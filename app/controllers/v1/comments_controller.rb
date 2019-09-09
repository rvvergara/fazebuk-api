# frozen_string_literal: true

class V1::CommentsController < ApplicationController
  before_action :pundit_user

  def create
    if set_commentable
      comment = build_comment
      if comment.save
        render :create, locals: { comment: comment }, status: :created
      else
        render json: { message: 'Cannot create comment', errors: comment.errors }, status: :unprocessable_entity
      end
    else
      commentable_type = params[:post_id] ? 'post' : 'comment'
      render json: { message: "Cannot find #{commentable_type}" }, status: 404
    end
  end

  def update
    comment = set_comment
    if comment
      if comment.update(update_params)
        render :update, locals: { comment: comment }, status: :accepted
      else
        render json: { message: 'Cannot update comment', errors: comment.errors }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Cannot find comment' }, status: 404
    end
  end

  def destroy
    comment = set_comment
    if comment
      comment.destroy
      render json: { message: 'Comment deleted' }, status: :accepted
    else
      render json: { message: 'Cannot find comment' }, status: 404
    end
  end

  private

  def update_params
    params.require(:comment).permit(:body).merge(commenter: pundit_user)
  end

  def set_comment
    pundit_user.authored_comments.find_by(id: params[:id])
  end
end
