# frozen_string_literal: true

class V1::Users::TimelinePostsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page.to_i
  end

  def index
    @user = User.find_by(username: params[:user_username])
    if @user
      records_per_page = 10
      posts_count = @user.timeline_posts.count
      @timeline_posts = @user.paginated_timeline_posts(@page, records_per_page)
      if @page <= max_page(posts_count, records_per_page)
        render :timeline_posts, status: :ok
      else
        render json: { message: 'No more timeline posts to show' }, status: :ok
      end
    else
      render json: { message: 'Cannot find user' }, status: 404
    end
  end
end
