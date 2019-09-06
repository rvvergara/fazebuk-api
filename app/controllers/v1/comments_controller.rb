# frozen_string_literal: true

class V1::CommentsController < ApplicationController
  before_action :pundit_user
  before_action :set_comment, except: [:create]

  def create
    if @commentable
      @comment = build_comment
      if @comment.save
        render :create, status: :created
      else
        render json: { message: 'Cannot create comment', errors: @comment.errors }, status: :unprocessable_entity
      end
    else
      commentable_type = params[:post_id] ? 'post' : 'comment'
      render json: { message: "Cannot find #{commentable_type}" }, status: 404
    end
  end

  def update
    if @comment
      if @comment.update(update_params)
        render :update, status: :accepted
      else
        render json: { message: 'Cannot update comment', errors: @comment.errors }
      end
    else
      render json: { message: 'Cannot find comment' }, status: 404
    end
  end

  def destroy; end

  private

  def update_params
    params.require(:comment).permit(:body).merge(commenter: @current_user)
  end

  def set_comment
    @comment = @current_user.authored_comments.find_by(id: params[:id])
  end
end
