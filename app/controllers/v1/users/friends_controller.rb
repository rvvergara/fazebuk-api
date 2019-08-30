# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user
  def all_friends
    @user = User.find_by(username: params[:user_username])
    @friends = @current_user.friends_with_tags(@user)
    render :friends, status: :ok
  end

  def mutual_friends
    @user = User.find_by(username: params[:user_username])
    @mutual_friends = @current_user.mutual_friends_with(@user)
    render :mutual_friends, status: :ok
  end
end
