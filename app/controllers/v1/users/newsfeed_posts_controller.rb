# frozen_string_literal: true

class V1::Users::NewsfeedPostsController < ApplicationController
  before_action do
    @page = set_page.to_i
  end

  def index
    records_per_page = 10
    posts_count = pundit_user.newsfeed_posts.count
    @newsfeed_posts = pundit_user.paginated_newsfeed_posts(@page, records_per_page)
    if set_max_in_page(@page, posts_count, records_per_page)
      render :newsfeed_posts, status: :ok
    else
      render json: { message: 'No more newsfeed posts to show' }, status: :ok
    end
  end
end
