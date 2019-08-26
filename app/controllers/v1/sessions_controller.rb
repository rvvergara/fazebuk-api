# frozen_string_literal: true

class V1::SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:email_or_username]) || User.find_by(username: params[:email_or_username])
    if @user &.valid_password?(params[:password])
      data = User.all.as_json.find { |user| user['username'] == @user.username }
      token = JsonWebToken.encode(data)
      render json: data.merge(token: token), status: :ok
    else
      render json: { "error": 'Cannot find' }
    end
  end
end
