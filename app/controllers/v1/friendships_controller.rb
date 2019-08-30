# frozen_string_literal: true

class V1::FriendshipsController < ApplicationController
  before_action :pundit_user
  before_action :find_friendship, only: %i[update destroy]

  def create
    @passive_friend = User.find_by(username: params[:friend_requested])
    @friendship = @current_user.active_friendships.build(passive_friend: @passive_friend)

    if @friendship.save
      render :create, status: :ok
    else
      render json: { message: 'Cannot send request', errors: @friendship.errors }
    end
  end

  def update
    @friendship.confirm
    render json: { message: 'Friend request confirmed!' }, status: :accepted
  end

  def destroy
    @friendship.destroy
    if @friendship.confirmed
      render json: { message: 'Friendship deleted' }, status: :accepted
    else
      message = @friendship.active_friend == @current_user ? 'Cancelled friend request' : 'Rejected friend request'
      render json: { message: message }, status: :accepted
    end
  end

  private

  def find_friendship
    @friendship = Friendship.find_by(id: params[:id])
    if @friendship
      authorize @friendship
    else
      render json: { message: 'Cannot find friendship' }, status: 404
      return
    end
  end
end
