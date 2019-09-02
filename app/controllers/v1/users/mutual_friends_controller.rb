# frozen_string_literal: true

class V1::Users::MutualFriendsController < ApplicationController
  before_action :pundit_user

  def index
    page = params[:page] || '1'
    @user = User.find_by(username: params[:user_username])
    @mutual_friends = @current_user.mutual_friends_with(@user, page)
    render :mutual_friends, status: :ok
  end
end
