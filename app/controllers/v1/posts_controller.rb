# frozen_string_literal: true

class V1::PostsController < ApplicationController
  before_action :pundit_user

  def create
    @postable = User.find_by(username: params[:post][:postable])
    if @postable
      post_params = { content: permitted_params[:content], postable: @postable }
      @post = @current_user.authored_posts.build(post_params)
      if @post.save
        render :create, status: :created
      else
        render json: { message: 'Cannot create post', errors: @post.errors }, status: :unprocessable_entity
      end
    else
      render json: { message: 'User does not exist' }
    end
  end

  def update; end

  def destroy; end

  private

  def permitted_params
    params.require(:post).permit(:content, :postable)
  end
end
