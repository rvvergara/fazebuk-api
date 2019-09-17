# frozen_string_literal: true

class User < ApplicationRecord
  include Rails.application.routes.url_helpers
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :order_created, -> { order(created_at: :asc) }

  validates :first_name, :last_name, :username, presence: true
  validates :username, uniqueness: true

  before_validation :downcase
  # before_update :assign_profile_pic, :assign_cover_pic

  has_many :active_friendships, foreign_key: :active_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :passive_friendships, foreign_key: :passive_friend_id, dependent: :destroy, class_name: 'Friendship'
  has_many :received_posts, foreign_key: :postable_id, dependent: :destroy, class_name: 'Post'
  has_many :authored_posts, foreign_key: :author_id, dependent: :destroy, class_name: 'Post'
  has_many :authored_comments, foreign_key: :commenter_id, dependent: :destroy, class_name: 'Comment'
  has_many :likes, foreign_key: :liker_id, dependent: :destroy
  has_many_attached :profile_images
  has_many_attached :cover_images

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
    User
      .order_created
      .where(id: active_friendships.where(confirmed: true).pluck(:passive_friend_id))
      .or(User.order_created.where(id: passive_friendships.where(confirmed: true).pluck(:active_friend_id)))
  end

  def pending_received_requests_from
    User
      .order_created
      .where(
        id: passive_friendships
          .where(confirmed: false)
          .pluck(:active_friend_id)
      )
  end

  def pending_sent_requests_to
    User
      .order_created
      .where(
        id: active_friendships
          .where(confirmed: false)
          .pluck(:passive_friend_id)
      )
  end

  def mutual_friends_with(other_user)
    friends
      .where(id: other_user.friends
          .pluck(:id))
  end

  def paginated_mutual_friends_with(other_user, page, per_page)
    mutual_friends_with(other_user)
      .limit(per_page)
      .offset(Pagination.offset(page, per_page))
  end

  def paginated_friends(page, per_page)
    friends
      .limit(per_page)
      .offset(Pagination.offset(page, per_page))
  end

  def existing_friendship_or_request_with?(friend)
    !active_friendships.or(passive_friendships)
      .where(
        'active_friend_id=:friend_id OR passive_friend_id=:friend_id', friend_id: friend.id
      ).empty? && self != friend
  end

  def friendship_id_with(friend)
    return unless existing_friendship_or_request_with?(friend)

    active_friendships.or(passive_friendships)
      .where('active_friend_id=:friend_id OR passive_friend_id=:friend_id', friend_id: friend.id).first.id
  end

  # Post related methods
  # posts shown on a user's page/timeline/profile

  def timeline_posts
    authored_posts.or(received_posts).order_created
  end

  def paginated_timeline_posts(page, per_page)
    timeline_posts
      .limit(per_page)
      .offset(Pagination.offset(page, per_page))
  end

  # posts shown on the newsfeed
  def newsfeed_posts
    feed_ids = friends.ids.concat([id])
    Post
      .order_created
      .where('author_id IN (:feed_ids) OR postable_id IN (:feed_ids)',
             feed_ids: feed_ids)
  end

  def paginated_newsfeed_posts(page, per_page)
    newsfeed_posts
      .limit(per_page)
      .offset(Pagination.offset(page, per_page))
  end

  # Like related methods
  def liked?(likeable)
    !likes.where('likeable_id=?', likeable.id).empty?
  end

  # Image uploads related methods
  def ordered_profile_images
    profile_images.order(created_at: :asc)
  end

  def assign_profile_pic
    self.profile_pic = rails_blob_path(ordered_profile_images.last, only_path: true)
    save
  end

  def assign_cover_pic
    self.cover_pic = rails_blob_path(cover_images.last, only_path: true)
    save
  end

  private

  def downcase
    return if username.nil? || email.nil?

    username.downcase!
    email.downcase!
  end
end
