# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page.to_i
  end

  def index
    @user = User.find_by(username: params[:user_username])
    records_per_page = 10
    @mutual_friends_count = @current_user.mutual_friends_with(@user).count
    @mutual_friends = @current_user.paginated_mutual_friends_with(@user, @page, records_per_page)
    if @page <= max_page(@mutual_friends_count, records_per_page)
      render :mutual_friends, status: :ok
    else
      render json: { message: 'No more mutual friends to show' }
    end
  end
end
