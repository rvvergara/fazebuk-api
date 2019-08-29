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

  def data
    User.all.as_json.find do |user|
      user['username'] == username
    end
  end

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
end
