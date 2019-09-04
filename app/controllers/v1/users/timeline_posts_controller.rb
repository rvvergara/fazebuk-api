# frozen_string_literal: true

class V1::Users::TimelinePostsController < ApplicationController
  before_action :pundit_user

  def index
    @user = User.find_by(username: params[:user_username])
    if @user
      @timeline_posts = @user.timeline_posts
      render :timeline_posts, status: :ok
    else
      render json: { message: 'Cannot find user' }, status: 404
    end
  end
end
