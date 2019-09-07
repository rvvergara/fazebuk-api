# frozen_string_literal: true

class V1::PostsController < ApplicationController
  before_action :pundit_user
  before_action :set_postable, except: [:destroy]
  before_action :set_post, except: [:create]

  def create
    set_postable
    @post = @current_user.authored_posts.build(post_params)
    if @post.save
      render :create, status: :created
    else
      render json: { message: 'Cannot create post', errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def update
    set_postable
    @post = set_post
    @post.postable_param = post_params[:postable]
    authorize @post

    if @post.update(post_params)
      render :update, status: :accepted
    else
      render json: { message: 'Cannot update post', errors: @post.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    post = set_post

    post.destroy
    render json: { message: 'Post deleted' }, status: :accepted
  end

  private

  def permitted_params
    params.require(:post).permit(:content, :postable)
  end

  def set_postable
    postable = User.find_by(username: params[:post][:postable])

    return postable if postable

    render json: { message: 'User does not exist' }, status: 404
  end

  def post_params
    { content: permitted_params[:content], postable: set_postable }
  end

  def set_post
    post = @current_user.authored_posts.find_by(id: params[:id])

    return post if post

    render json: { message: 'Post does not exist' }, status: 404
  end
end
