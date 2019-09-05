# frozen_string_literal: true

class V1::PostsController < ApplicationController
  before_action :pundit_user, :set_postable
  before_action :set_post, except: [:create]
  def create
    if @postable
      @post = @current_user.authored_posts.build(post_params)
      if @post.save
        render :create, status: :created
      else
        render json: { message: 'Cannot create post', errors: @post.errors }, status: :unprocessable_entity
      end
    else
      render json: { message: 'User does not exist' }, status: 404
    end
  end

  def update
    if @post && @postable
      @post.postable_param = post_params[:postable]
      authorize @post
      if @post.update(post_params)
        render :update, status: :accepted
      else
        render json: { message: 'Cannot update post', errors: @post.errors }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Post or user does not exist' }, status: 404
    end
  end

  def destroy; end

  private

  def permitted_params
    params.require(:post).permit(:content, :postable)
  end

  def set_postable
    @postable = User.find_by(username: params[:post][:postable])
  end

  def post_params
    { content: permitted_params[:content], postable: @postable }
  end

  def set_post
    @post = @current_user.authored_posts.find_by(id: params[:id])
  end
end
