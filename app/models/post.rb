# frozen_string_literal: true

class Post < ApplicationRecord
  attr_accessor :postable_param, :purge_pic
  attribute :adding_or_purging_pic, :boolean, default: false

  belongs_to :postable, class_name: 'User'
  belongs_to :author, class_name: 'User'
  has_many :comments, foreign_key: :commentable_id, as: :commentable, dependent: :destroy
  has_many :likes, foreign_key: :likeable_id, as: :likeable, dependent: :destroy
  has_many_attached :pics, dependent: :purge

  scope :order_created, -> { order(created_at: :desc) }

  validates :content, presence: true, unless: :adding_or_purging_pic?

  def modified_update(post_params)
    if post_params[:purge_pic]
      purge_id = post_params[:purge_pic]
      pic = pics.find_by(id: purge_id)
      pic.purge_later
      self.adding_or_purging_pic = true unless pics.count.zero?
      save
    elsif post_params[:pics]
      self.adding_or_purging_pic = true
    end
    update(post_params)
    self.adding_or_purging_pic = false
  end
end
