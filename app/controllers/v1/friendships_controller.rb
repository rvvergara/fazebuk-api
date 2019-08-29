# frozen_string_literal: true

class V1::FriendshipsController < ApplicationController
  before_action :pundit_user

  def index
    @user = User.find_by(username: params[:user_username])
    @friends = @current_user.friends_with_tags(@user)
    render :friends, status: :ok
  end

  def create
    @passive_friend = User.find_by(username: params[:user_username])
    @friendship = @current_user.active_friendships.build(passive_friend: @passive_friend)

    if @friendship.save
      render :create, status: :ok
    else
      render json: { message: 'Cannot send request', errors: @friendship.errors }
    end
  end

  def update; end

  def destroy; end
end
