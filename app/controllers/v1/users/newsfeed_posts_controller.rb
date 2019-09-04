# frozen_string_literal: true

class V1::Users::NewsfeedPostsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page
  end

  def index
    records_per_page = 10
    max_page = (@current_user.newsfeed_posts.count / records_per_page.to_f).ceil
    @newsfeed_posts = @current_user.paginated_newsfeed_posts(@page, records_per_page)
    if @page.to_i <= max_page
      render :newsfeed_posts, status: :ok
    else
      render json: { message: 'No more newsfeed posts to show'}, status: :ok
    end
  end
end
