# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user

  def index
    @user = User.find_by(username: params[:user_username])
    @friends = @user.friends_with_tags(@current_user)
    render :friends, status: :ok
  end
end
