# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Friends', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let(:gerry) { create(:user, :male, first_name: 'Gerry') }
  let!(:friends) do
    8.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: user, passive_friend: harry)
      create(:friendship, :confirmed, active_friend: gerry, passive_friend: user)
    end

    7.times do
      user = create(:user, :male, username: generate(:username))
      create(:friendship, :confirmed, active_friend: harry, passive_friend: user)
      create(:friendship, :confirmed, active_friend: user, passive_friend: gerry)
    end
  end

  def mutual_friends_route(username, page = nil)
    page_param = page ? "?page=#{page}" : nil
    "/v1/users/#{username}/mutual_friends#{page_param}"
  end

  describe 'unauthenticated user request' do
    it {
      get mutual_friends_route(gerry.username)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/users/:user_username/friends' do
    let!(:login) { login_as(harry) }

    context 'request without specified page' do
      it 'responds with first page (10 friends)' do
        get mutual_friends_route(gerry.username),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(mutual_friends_response_keys)
        expect(json_response['total_shown_on_page']).to be(10)
      end
    end

    context 'request for page 2' do
      it 'responds with second page (5 friends)' do
        get mutual_friends_route(gerry.username, 2),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(mutual_friends_response_keys)
        expect(json_response['total_shown_on_page']).to be(5)
      end
    end

    context 'request for page 3' do
      it 'sends a no more to display message' do
        get mutual_friends_route(gerry.username, 3),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to match('No more mutual friends to show')
      end
    end
  end
end
