# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page.to_i
  end

  def index
    @user = User.find_by(username: params[:user_username])
    records_per_page = 10
    @friends_count = @user.friends.count
    @friends = @user.paginated_friends(@page, records_per_page)

    if set_max_in_page(@page, @friends_count, records_per_page)
      render :friends, status: :ok
    else
      render json: { message: 'No more friends to show' }
    end
  end
end
