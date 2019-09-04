# frozen_string_literal: true

class V1::Users::TimelinePostsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page
  end

  def index
    @user = User.find_by(username: params[:user_username])
    if @user
      records_per_page = 10
      @timeline_posts = @user.timeline_posts(@page, records_per_page)
      render :timeline_posts, status: :ok
    else
      render json: { message: 'Cannot find user' }, status: 404
    end
  end
end
