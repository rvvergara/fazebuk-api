# frozen_string_literal: true

class V1::PostsController < ApplicationController
  before_action :pundit_user

  def show
    post = Post.find_by(id: params[:id])

    if post
      render :show, locals: { post: post }, status: :ok
    else
      find_error('post')
    end
  end

  def create
    post = pundit_user.authored_posts.build(post_params)
    if post.save
      render :create, locals: { post: post }, status: :created
    else
      process_error(post, 'Cannot create post')
    end
  end

  def update
    post = set_post
    authorize_post(post)

    if post&.update(post_params)
      render :update, locals: { post: post }, status: :accepted
    elsif post
      process_error(post, 'Cannot update post')
    end
  end

  def destroy
    post = set_post
    post&.destroy

    action_success('Post deleted') if post
  end

  private

  def permitted_params
    params.require(:post).permit(:content, :postable, pics: [])
  end

  def set_postable
    User.find_by(username: params[:post][:postable])
  end

  def post_params
    pics_params = { pics: permitted_params[:pics] }
    sent_params = { content: permitted_params[:content], postable: set_postable }
    pics_params[:pics].nil? ? sent_params : sent_params.merge(pics_params)
  end

  def set_post
    post = pundit_user.authored_posts.find_by(id: params[:id])

    find_error('post') unless post

    post
  end

  def authorize_post(post)
    return unless post

    post.postable_param = post_params[:postable] if post
    authorize post if post.postable_param
  end
end
