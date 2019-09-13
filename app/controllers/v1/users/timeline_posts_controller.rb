# frozen_string_literal: true

class V1::Users::TimelinePostsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    user = find_user
    return unless user

    records_per_page = 10
    posts_count = user.timeline_posts.count
    timeline_posts = user.paginated_timeline_posts(page, records_per_page)

    if set_max_in_page(page, posts_count, records_per_page)
      render :index,
             locals: {
               user: user,
               timeline_posts: timeline_posts,
               page: page
             },
             status: :ok
    else
      action_success('No more timeline posts to show', :ok)
    end
  end
end
