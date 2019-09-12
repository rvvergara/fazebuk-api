# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { message: 'You are not authorized to do that' }, status: :unauthorized
  end

  def pundit_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      decoded = JsonWebToken.decode(header)
      return User.find(decoded['id'])
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'You are not authorized' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { message: 'Unauthorized access' }, status: :unauthorized
    end
  end

  def find_user
    user = User.find_by(username: params[:user_username])
    return user if user

    render_error('user')
    nil
  end

  def set_page
    Pagination.page(params[:page]).to_i
  end

  def set_max_in_page(page, record_count, records_per_page)
    Pagination.set_max_in_page(page, record_count, records_per_page)
  end

  def shown_attributes(user)
    {
      id: user.id,
      username: user.username,
      email: user.email,
      first_name: user.first_name,
      middle_name: user.middle_name,
      last_name: user.last_name,
      bio: user.bio,
      birthday: user.birthday,
      gender: user.gender
    }
  end

  def render_error(resource_type)
    render json: { message: "Cannot find #{resource_type}" }, status: 404
  end
end
