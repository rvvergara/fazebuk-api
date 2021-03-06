# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user

  def index
    page = set_page

    user = find_user
    return unless user

    records_per_page = 10
    total_mutual_friends_count = pundit_user.mutual_friends_with(user).count
    displayed_mutual_friends = pundit_user.paginated_mutual_friends_with(user, page, records_per_page)

    if set_max_in_page(page, total_mutual_friends_count, records_per_page)
      render :index,
             locals: {
               user: user,
               displayed_mutual_friends: displayed_mutual_friends, total_mutual_friends_count:
               total_mutual_friends_count,
               page: page
             },
             status: :ok
    elsif pundit_user == user
      action_success('You do not have mutual friends with yourself', :ok)
    else
      action_success('No more mutual friends to show', :ok)
    end
  end
end
