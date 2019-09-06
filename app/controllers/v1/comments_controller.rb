# frozen_string_literal: true

class V1::CommentsController < ApplicationController
  before_action :pundit_user

  def create
    if @commentable
      @comment = build_comment
      if @comment.save
        render :create, status: :created
      else
        render json: { message: 'Cannot create comment', errors: @comment.errors }
      end
    else
      commentable_type = @commentable.type == 'Posts' ? 'post' : 'comment'
      render json: { message: "Cannot find #{commentable_type}" }
    end
  end

  def update; end

  def destroy; end
end
