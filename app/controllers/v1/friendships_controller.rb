# frozen_string_literal: true

class V1::FriendshipsController < ApplicationController
  before_action :pundit_user

  def create
    passive_friend = User.find_by(username: params[:friend_requested])
    friendship = pundit_user.active_friendships.build(passive_friend: passive_friend)

    if friendship.save
      render :create, locals: { passive_friend: passive_friend }, status: :ok
    else
      render json: { message: 'Cannot send request', errors: friendship.errors }
    end
  end

  def update
    return unless find_friendship

    find_friendship.confirm
    render json: { message: 'Friend request confirmed!' }, status: :accepted
  end

  def destroy
    friendship = find_friendship
    friendship.destroy
    if friendship.confirmed
      render json: { message: 'Friendship deleted' }, status: :accepted
    else
      message = friendship.active_friend == pundit_user ? 'Cancelled friend request' : 'Rejected friend request'
      render json: { message: message }, status: :accepted
    end
  end

  private

  def find_friendship
    friendship = Friendship.order_created.find_by(id: params[:id])
    if friendship
      authorize friendship
      return friendship
    else
      render json: { message: 'Cannot find resource' }, status: 404
      return false
    end
  end
end
