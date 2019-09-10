# frozen_string_literal: true

class V1::LikesController < ApplicationController
  before_action :pundit_user

  def create
    like = build_like

    if like.save
      likeable_type = like.likeable_type.downcase!

      render json: { message: "Successfully liked #{likeable_type}" }, status: :created
    else
      render json: { message: 'Cannot like resource', errors: like.errors }, status: :unprocessable_entity
    end
  end

  def destroy; end
end
