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
      @current_user = User.find(decoded['id'])
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'You are not authorized' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { message: 'Unauthorized access' }, status: :unauthorized
    end
  end

  def set_page
    params[:page] || '1'
  end
end
