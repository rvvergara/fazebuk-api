# frozen_string_literal: true

class V1::FriendshipsController < ApplicationController
  before_action :pundit_user

  def index
    @user = User.find_by(username: params[:user_username])
    @friends = @user.friends
    render json: @friends, status: :ok
  end

  def create; end

  def update; end

  def destroy; end
end
