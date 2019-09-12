# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::TimelinePosts', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let!(:friends) do
    8.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: user, passive_friend: harry)
      create(:post, author: harry, postable: user)
    end

    7.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: harry, passive_friend: user)
      create(:post, author: user, postable: harry)
    end
  end

  def timeline_posts_route(username, page = nil)
    page_param = page ? "?page=#{page}" : nil
    "/v1/users/#{username}/timeline_posts#{page_param}"
  end

  describe 'unauthenticated user request' do
    it {
      get timeline_posts_route(harry.username)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe '/v1/users/username/:user_username/timeline_posts' do
    let!(:login) { login_as(harry) }

    context 'user exists' do
      context 'page params not included in request' do
        it 'shows first page (10 posts)' do
          get timeline_posts_route(harry.username),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response.keys).to match(timeline_posts_response_keys)
          expect(json_response['total_shown_on_page']).to be(10)
        end
      end

      context 'page params is 2' do
        it 'displays page 2 (5 posts)' do
          get timeline_posts_route(harry.username, 2),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response.keys).to match(timeline_posts_response_keys)
          expect(json_response['total_shown_on_page']).to be(5)
        end
      end

      context 'page params is 3' do
        it 'shows no posts' do
          get timeline_posts_route(harry.username, 3),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to match('No more timeline posts to show')
        end
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        get timeline_posts_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end
end
