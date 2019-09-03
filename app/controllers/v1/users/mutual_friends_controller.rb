# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page
  end

  def index
    @user = User.find_by(username: params[:user_username])
    records_per_page = 10
    @mutual_friends = @current_user.mutual_friends_with(@user, @page, records_per_page)
    render :mutual_friends, status: :ok
  end
end
