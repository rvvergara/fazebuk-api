# frozen_string_literal: true

class V1::FacebookAuthenticationsController < ApplicationController
  def create
    facebook_access_token = params.require(:access_token)
    @facebook_data = User.find_or_create_with_facebook(facebook_access_token)
    if @facebook_data.class == User
      data = @facebook_data.shown_attributes
      @token = JsonWebToken.encode(data)
      render :user, status: :ok
    else
      render json: @facebook_data, status: :unprocessable_entity
    end
  end
end
