# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  default_scope { order(created_at: :asc) }

  validates :first_name, :last_name, :username, presence: true
  validates :username, uniqueness: true

  has_many :active_friendships, foreign_key: :active_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :passive_friendships, foreign_key: :passive_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :received_posts, foreign_key: :postable_id, dependent: :destroy, class_name: 'Post'
  has_many :authored_posts, foreign_key: :author_id, dependent: :destroy, class_name: 'Post'

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

  # Friendship related methods
  def friends
    User.where(id: active_friendships.where(confirmed: true).pluck(:passive_friend_id))
      .or(User.where(id: passive_friendships.where(confirmed: true).pluck(:active_friend_id)))
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

  def mutual_friends_with(other_user, page, per_page)
    offset = (page.to_i - 1) * per_page
    friends
      .where(id: other_user.friends
          .pluck(:id))
      .limit(per_page).offset(offset)
  end

  def paginated_friends(page, per_page)
    friends
      .limit(per_page)
      .offset(offset(page, per_page))
  end

  # Post related methods
  # posts shown on a user's page/timeline/profile
  def timeline_posts(page, per_page)
    authored_posts
      .or(received_posts)
      .limit(per_page)
      .offset(offset(page, per_page))
  end

  # posts shown on the newsfeed
  def newsfeed_posts
    feed_ids = friends.ids.concat([id])
    Post
      .where('author_id IN (:feed_ids) OR postable_id IN (:feed_ids)',
             feed_ids: feed_ids)
  end

  def paginated_newsfeed_posts(page, per_page)
    newsfeed_posts
      .limit(per_page)
      .offset(offset(page, per_page))
  end
end
