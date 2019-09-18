# frozen_string_literal: true

module ApplicationHelper
  def convert_to_i(date)
    date.to_time.to_i
  end

  def pic_url(pic)
    rails_blob_path(pic, only_path: true)
  end

  def cover_pic(user)
    user.ordered_cover_images.first
  end

  def profile_pic(user)
    user.ordered_profile_images.first
  end
end
