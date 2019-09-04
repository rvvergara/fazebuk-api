# frozen_string_literal: true

class V1::Users::NewsfeedPostsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page
  end

  def index
    records_per_page = 10
    @newsfeed_posts = @current_user.newsfeed_posts(@page, records_per_page)
  end
end
