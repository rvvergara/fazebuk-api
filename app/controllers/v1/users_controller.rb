# frozen_string_literal: true

class V1::UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username])
    if @user
      render :user, status: :ok
    else
      render json: { message: 'Cannot find user' }, status: 404
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @token = JsonWebToken.encode(@user.data)
      render json: @user.data.merge(token: @token), status: :created
    else
      render json: { message: 'Cannot create user', errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :username,
      :password,
      :password_confirmation,
      :first_name,
      :last_name,
      :middle_name,
      :bio,
      :birthday,
      :gender
    )
  end
end
