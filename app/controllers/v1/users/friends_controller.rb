# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    user = User.find_by(username: params[:user_username])
    records_per_page = 10
    friends_count = user.friends.count
    friends = user.paginated_friends(page, records_per_page)

    if set_max_in_page(page, friends_count, records_per_page)
      render :friends,
             locals: {
               user: user,
               friends: friends,
               page: page,
               friends_count: friends_count
             },
             status: :ok
    else
      render json: { message: 'No more friends to show' }
    end
  end
end
