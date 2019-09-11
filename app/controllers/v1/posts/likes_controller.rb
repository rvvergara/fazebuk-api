# frozen_string_literal: true

class V1::Posts::LikesController < V1::LikesController
  before_action :set_likeable

  private

  def set_likeable
    post = Post.find_by(id: params[:post_id])
    return post if post

    render_error('post')
    nil
  end
end
