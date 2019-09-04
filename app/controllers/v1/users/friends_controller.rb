# frozen_string_literal: true

class V1::Users::FriendsController < ApplicationController
  before_action :pundit_user
  before_action do
    @page = set_page
  end

  def index
    @user = User.find_by(username: params[:user_username])
    records_per_page = 10
    @friends = @user.paginated_friends(@page, records_per_page)
    render :friends, status: :ok
  end
end
