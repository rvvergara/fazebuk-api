# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page
    user = find_user
    return unless user

    records_per_page = 10
    all_friends = user.friends
    total_friends_count = all_friends.count
    displayed_friends = user.paginated_friends(page, records_per_page)

    if set_max_in_page(page, total_friends_count, records_per_page)
      render :friends,
             locals: {
               user: user,
               displayed_friends: displayed_friends,
               page: page,
               total_friends_count: total_friends_count
             },
             status: :ok
    else
      render json: { message: 'No more friends to show' }
    end
  end
end
