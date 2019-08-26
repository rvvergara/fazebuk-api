# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe '#show' do
    let(:alfred) { create(:user, username: 'alfred') }

    context 'logged user' do
      before do
        login_as(alfred)
        @token = user_token
      end
      it 'returns a good response' do
        get "/v1/users/#{alfred.username}", headers: { "Authorization": "Bearer #{@token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['user']['data']['username']).to eq(alfred.username)
      end
    end

    context 'unauthenticated user' do
      it 'returns an error message' do
        get "/v1/users/#{alfred.username}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
