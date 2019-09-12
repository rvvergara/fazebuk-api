# frozen_string_literal: true

class V1::LikesController < ApplicationController
  before_action :pundit_user

  def create
    like = build_like
    return unless like

    if like.save
      likeable_type = like.likeable_type.downcase!

      render json: { message: "Successfully liked #{likeable_type}" }, status: :created
    else
      render json: { message: 'Cannot like resource', errors: like.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    like = find_like
    return unless like

    like.destroy
    likeable_type = like.likeable_type.downcase
    render json: { message: "Unliked #{likeable_type}" }, status: :accepted
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
