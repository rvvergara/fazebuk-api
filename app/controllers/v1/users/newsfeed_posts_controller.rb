# frozen_string_literal: true

class V1::Users::NewsfeedPostsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    records_per_page = 10
    posts_count = pundit_user.newsfeed_posts.count
    newsfeed_posts = pundit_user.paginated_newsfeed_posts(page, records_per_page)
    if set_max_in_page(page, posts_count, records_per_page)
      render :index,
             locals: {
               newsfeed_posts: newsfeed_posts,
               page: page
             },
             status: :ok
    else
      action_success('No more newsfeed posts to show', :ok)
    end
  end
end
