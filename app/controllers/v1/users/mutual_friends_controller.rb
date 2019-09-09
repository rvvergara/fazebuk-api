# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    user = User.find_by(username: params[:user_username])
    records_per_page = 10
    mutual_friends_count = pundit_user.mutual_friends_with(user).count
    mutual_friends = pundit_user.paginated_mutual_friends_with(user, page, records_per_page)

    if set_max_in_page(page, mutual_friends_count, records_per_page)
      render :mutual_friends,
             locals: {
               user: user,
               mutual_friends: mutual_friends, mutual_friends_count: mutual_friends_count,
               page: page
             },
             status: :ok
    else
      render json: { message: 'No more mutual friends to show' }
    end
  end
end
