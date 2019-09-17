# frozen_string_literal: true

class V1::UsersController < ApplicationController
  before_action :pundit_user, except: [:create]

  def show
    user = find_user
    return unless user

    render :show, locals: { user: user }, status: :ok
  end

  def create
    user = User.new(user_params)

    if user.save
      token = JsonWebToken.encode(user.attributes)
      render :create, locals: { user: user, token: token }, status: :created
    else
      process_error(user, 'Cannot create user')
    end
  end

  def update
    user = find_user
    return unless user
    debugger
    authorize user
    if user.update(user_params)

      update_pics(user)

      render :show, locals: { user: user }, status: :accepted
    else
      process_error(user, 'Cannot update user')
    end
  end

  def destroy
    user = find_user
    return unless user

    authorize user

    user.destroy
    action_success('Account deleted')
  end

  private

  def find_user
    user = User.find_by(username: params[:username])
    return user if user

    find_error('user')
    nil
  end

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
      :gender,
      :profile_pic,
      :cover_pic,
      profile_images: [],
      cover_images: []
    )
  end

  def update_pics(user)
    user.assign_profile_pic unless user_params[:profile_images].nil?

    user.assign_cover_pic unless user_params[:cover_images].nil?
  end
end
