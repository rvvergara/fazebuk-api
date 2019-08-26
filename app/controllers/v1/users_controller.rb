class V1::UsersController < ApplicationController
  def show
    @user = User.friendly.find(params[:id])
  end
end
