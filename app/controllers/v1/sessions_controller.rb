# frozen_string_literal: true

class V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user &.valid_password?(params[:password])
      data = shown_attributes(user)
      token = JsonWebToken.encode(data)
      render :user, locals: { user: user, token: token }, status: :ok
    else
      render json: { "message": 'Invalid credentials' }, status: :unauthorized
    end
  end
end
