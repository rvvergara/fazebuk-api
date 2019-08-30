# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user

  def index
    @user = User.find_by(username: params[:user_username])
    @mutual_friends = @current_user.mutual_friends_with(@user)
    render :mutual_friends, status: :ok
  end
end
