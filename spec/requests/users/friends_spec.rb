# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Friends', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let!(:friends) do
    8.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: user, passive_friend: harry)
    end

    7.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: harry, passive_friend: user)
    end
  end

  def friends_route(username, page = nil)
    page_param = page ? "?page=#{page}" : nil
    "/v1/users/#{username}/friends#{page_param}"
  end

  describe 'unauthenticated user request' do
    it {
      get friends_route(harry.username)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/users/:user_username/friends' do
    let!(:login) { login_as(harry) }

    context 'user exists' do
      context 'request without specified page' do
        it 'responds with first page (10 friends)' do
          get friends_route(harry.username),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response.keys).to match(friends_response_keys)
          expect(json_response['total_shown_on_page']).to be(10)
        end
      end

      context 'request for page 2' do
        it 'responds with second page (5 friends)' do
          get friends_route(harry.username, 2),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response.keys).to match(friends_response_keys)
          expect(json_response['total_shown_on_page']).to be(5)
        end
      end

      context 'request for page 3' do
        it 'sends a no more to display message' do
          get friends_route(harry.username, 3),
              headers: authorization_header

          expect(response).to have_http_status(:ok)
          expect(json_response['message']).to match('No more friends to show')
        end
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        get friends_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end
end
