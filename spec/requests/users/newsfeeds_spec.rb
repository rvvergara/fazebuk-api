# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Newsfeeds', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let(:gerry) { create(:user, :male, first_name: 'Gerry') }
  let!(:friends) do
    4.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: user, passive_friend: harry)
      create(:friendship, :confirmed, active_friend: gerry, passive_friend: user)
      create(:post, author: harry, postable: user)
      create(:post, author: user, postable: gerry)
    end

    3.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: harry, passive_friend: user)
      create(:friendship, :confirmed, active_friend: user, passive_friend: gerry)
      create(:post, author: user, postable: harry)
      create(:post, author: gerry, postable: user)
    end
  end

  describe 'unauthenticated user request' do
    it {
      get newsfeed_route
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/newsfeed_posts' do
    let!(:login) { login_as(harry) }

    context 'when no page params included' do
      it 'shows page 1 (10 posts)' do
        get newsfeed_route,
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(newsfeed_posts_response_keys)
        expect(json_response['total_shown_on_page']).to be(10)
      end
    end

    context 'when page 2 in params' do
      it 'shows page 2 (4 posts)' do
        get newsfeed_route(2),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(newsfeed_posts_response_keys)
        expect(json_response['total_shown_on_page']).to be(4)
      end
    end

    context 'when page 3 in params' do
      it 'sends no posts' do
        get newsfeed_route(3),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to match('No more newsfeed posts to show')
      end
    end
  end
end
