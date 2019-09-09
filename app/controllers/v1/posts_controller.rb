# frozen_string_literal: true

class V1::PostsController < ApplicationController
  def show
    post = Post.find_by(id: params[:id])

    if post
      render :show, locals: { post: post }, status: :ok
    else
      render_error('Post does not exist', 404)
    end
  end

  def create
    post = pundit_user.authored_posts.build(post_params)
    if post.save
      render :create, locals: { post: post }, status: :created
    else
      render_error('Cannot create post', 422, post.errors)
    end
  end

  def update
    post = set_post
    authorize_post(post)

    if post&.update(post_params)
      render :update, locals: { post: post }, status: :accepted
    elsif post
      render_error('Cannot update post', 422, post.errors)
    end
  end

  def destroy
    post = set_post
    post&.destroy

    render json: { message: 'Post deleted' }, status: :accepted if post
  end

  private

  def permitted_params
    params.require(:post).permit(:content, :postable)
  end

  def set_postable
    User.find_by(username: params[:post][:postable])
  end

  def post_params
    { content: permitted_params[:content], postable: set_postable }
  end

  def set_post
    post = pundit_user.authored_posts.find_by(id: params[:id])

    render_error('Post does not exist', 404) unless post

    post
  end

  def authorize_post(post)
    return unless post

    post.postable_param = post_params[:postable] if post
    authorize post if post.postable_param
  end

  def render_error(message, err_status, error_data = nil)
    err_json = { message: message }
    err_json = err_json.merge(errors: error_data) if error_data
    render json: err_json, status: err_status
  end
end
