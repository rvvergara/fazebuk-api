# frozen_string_literal: true

class Comment < ApplicationRecord
  attribute :adding_or_purging_pic, :boolean, default: false
  attr_accessor :purge_pic
  belongs_to :commenter, class_name: 'User'
  belongs_to :commentable, polymorphic: true
  has_many :replies, foreign_key: :commentable_id, class_name: 'Comment', as: :commentable, dependent: :destroy
  has_many :likes, foreign_key: :likeable_id, as: :likeable, dependent: :destroy
  has_one_attached :pic, dependent: :purge

  default_scope { order(updated_at: :asc) }

  validates :body, presence: true, unless: :adding_or_purging_pic?

  def modified_update(update_params)
    if update_params[:pic]
      self.adding_or_purging_pic = true
    elsif update_params[:purge_pic]
      pic.purge
      save
    end

    update_stat = update(update_params)
    self.adding_or_purging_pic = false
    update_stat
  end
end
