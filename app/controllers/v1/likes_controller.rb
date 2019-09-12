# frozen_string_literal: true

class V1::LikesController < ApplicationController
  before_action :pundit_user

  def create
    like = build_like
    return unless like

    if like.save
      likeable_type = like.likeable_type.downcase!

      action_success( "Successfully liked #{likeable_type}", :created)
    else
      process_error(like, 'Cannot like resource')
    end
  end

  def destroy
    like = find_like
    return unless like

    like.destroy
    likeable_type = like.likeable_type.downcase
    action_success("Unliked #{likeable_type}")
  end

  private

  def build_like
    return unless set_likeable

    pundit_user.likes.build(likeable: set_likeable)
  end

  def find_like
    like = Like.find_by(id: params[:id])
    return like if like

    find_error('like record')
    nil
  end
end
