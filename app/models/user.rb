# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :username, presence: true
  validates :username, uniqueness: true

  has_many :active_friendships, foreign_key: :active_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :passive_friendships, foreign_key: :passive_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :active_friends, through: :passive_friendships, source: :active_friend, dependent: :destroy
  has_many :passive_friends, through: :active_friendships, source: :passive_friend, dependent: :destroy

  def self.find_or_create_with_facebook(token)
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me', fields: %w[email first_name middle_name last_name])
    data = {
      email: profile['email'],
      first_name: profile['first_name'],
      middle_name: profile['middle_name'],
      last_name: profile['last_name'],
      username: profile['id'],
      password: SecureRandom.urlsafe_base64
    }
    user = User.find_by(email: profile['email'])
    return user if user

    User.create(data)
  rescue StandardError => e
    message = e.to_json.split(',')[2].split(':')
    {
      message[0].to_sym => message[1]
    }
  end

  def friends
    User.where(id: active_friendships.pluck(:passive_friend_id))
      .or(User.where(id: passive_friendships.pluck(:active_friend_id)))
  end

  def pending_received_requests_from
    User.where(
      id: passive_friendships
        .where(confirmed: false)
        .pluck(:active_friend_id)
    )
  end

  def pending_sent_requests_to
    User.where(
      id: active_friendships
        .where(confirmed: false)
        .pluck(:passive_friend_id)
    )
  end

  def mutual_friends_with(other_user)
    User
      .where(id: friends.pluck(:id))
      .where(id: other_user.friends.pluck(:id))
  end

  def user_with_tag(viewed_user)
    # Check if viewed_user has a sent request
    received_request_from_this_user = pending_received_requests_from.include?(viewed_user)
    # Check if viewed_user has a received request
    sent_request_to_this_user = pending_sent_requests_to.include?(viewed_user)
    # Check if viewed_user is already a friend.
    is_already_a_friend = friends.include?(viewed_user)

    viewed_user.attributes
      .merge(received_request_from_this_user: received_request_from_this_user)
      .merge(sent_request_to_this_user: sent_request_to_this_user)
      .merge(is_already_a_friend: is_already_a_friend)
  end

  def friends_with_tags(other_user)
    other_user.friends.map do |friend|
      user_with_tag(friend)
    end
  end
end
