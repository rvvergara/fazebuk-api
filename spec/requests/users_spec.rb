# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /v1/users/:username' do
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
        expect(JSON.parse(response.body)['message']).to match('Unauthorized')
      end
    end
  end

  describe 'POST /v1/users' do
    context 'correct and complete user data' do
      it 'creates & authenticates user' do
        user_attributes = attributes_for(:user)

        expect do
          post '/v1/users', params: { user: user_attributes }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        expect(JSON.parse(response.body)['user']['token']).to_not be(nil)
      end
    end

    context 'first name missing' do
      it 'does not create a user' do
        invalid_attributes = attributes_for(:user, first_name: nil)
        expect do
          post '/v1/users', params: { user: invalid_attributes }
        end.to_not change(User, :count)

        expect(JSON.parse(response.body)['message']).to match('Cannot create user')
      end
    end

    context 'duplicate username' do
      it 'does not create user' do
        arnold = create(:user, username: 'arnold')
        duplicate_attributes = attributes_for(:user, username: arnold.username)

        expect do
          post '/v1/users', params: { user: duplicate_attributes }
        end.to_not change(User, :count)

        expect(JSON.parse(response.body)['errors']['username']).to include('has already been taken')
      end
    end
  end
end
