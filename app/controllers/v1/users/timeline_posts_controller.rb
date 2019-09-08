# frozen_string_literal: true

class V1::Users::TimelinePostsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    user = User.find_by(username: params[:user_username])
    if user
      records_per_page = 10
      posts_count = user.timeline_posts.count
      timeline_posts = user.paginated_timeline_posts(page, records_per_page)

      if set_max_in_page(page, posts_count, records_per_page)
        render :timeline_posts,
               locals: {
                 user: user,
                 timeline_posts: timeline_posts,
                 page: page
               },
               status: :ok
      else
        render json: { message: 'No more timeline posts to show' }, status: :ok
      end
    else
      render json: { message: 'Cannot find user' }, status: 404
    end
  end
end
