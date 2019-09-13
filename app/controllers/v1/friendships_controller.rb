# frozen_string_literal: true

class V1::FriendshipsController < ApplicationController
  before_action :pundit_user

  def create
    passive_friend = User.find_by(username: params[:friend_requested])
    friendship = pundit_user.active_friendships.build(passive_friend: passive_friend)

    if friendship.save
      render :create, locals: { passive_friend: passive_friend }, status: :created
    else
      process_error(friendship, 'Cannot send request')
    end
  end

  def update
    return unless find_friendship

    find_friendship.confirm
    action_success('Friend request confirmed!')
  end

  def destroy
    friendship = find_friendship
    return unless friendship

    friendship.destroy
    delete_request_message(friendship)
  end

  private

  def find_friendship
    friendship = Friendship.order_created.find_by(id: params[:id])

    if friendship
      authorize friendship
      return friendship
    end
    find_error('friendship or request')
    nil
  end

  def delete_request_message(friendship)
    if friendship.confirmed
      action_success('Friendship deleted')
    else
      message = friendship.active_friend == pundit_user ? 'Cancelled friend request' : 'Rejected friend request'
      action_success(message)
    end
  end
end
