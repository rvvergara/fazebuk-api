# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:alfred) { create(:user, :male, first_name: 'Alfred') }
  let!(:arnold) { create(:user, :male, first_name: 'Arnold') }
  let(:duplicate_attributes) { attributes_for(:user, :male, username: arnold.username) }
  let(:valid_attributes) { attributes_for(:user, :male) }
  let(:invalid_attributes) { attributes_for(:user, :male, :invalid, first_name: nil) }
  let!(:login) { login_as(alfred) }

  describe 'GET /v1/users/:username' do
    context 'logged user' do
      it 'returns a good response' do
        get "/v1/users/#{alfred.username}", headers: { "Authorization": "Bearer #{user_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['username']).to eq(alfred.username)
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
        expect do
          post '/v1/users', params: { user: valid_attributes }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        expect(JSON.parse(response.body)['user']['token']).to eq(user_token)
      end
    end

    context 'first name missing' do
      it 'does not create a user' do
        expect do
          post '/v1/users', params: { user: invalid_attributes }
        end.to_not change(User, :count)

        expect(JSON.parse(response.body)['message']).to match('Cannot create user')
      end
    end

    context 'duplicate username' do
      it 'does not create user' do
        expect do
          post '/v1/users', params: { user: duplicate_attributes }
        end.to_not change(User, :count)

        expect(JSON.parse(response.body)['errors']['username']).to include('has already been taken')
      end
    end
  end

  describe 'PUT /v1/users/:username' do
    context 'authenticated user' do
      context 'updating own account' do
        it 'is accepted' do
          put "/v1/users/#{alfred.username}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { user: { first_name: 'King' } }
          alfred.reload
          expect(response).to have_http_status(:accepted)
          expect(JSON.parse(response.body)['first_name']).to eq('King')
          expect(alfred.first_name).to eq('King')
        end
      end

      context "attempting to update other user's account" do
        it 'is unauthorized' do
          put "/v1/users/#{arnold.username}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { user: { first_name: 'Booger' } }

          expect(response).to have_http_status(:unauthorized)
          arnold.reload
          expect(arnold.first_name).to eq('Arnold')
        end
      end
    end

    context 'unauthenticated user' do
      it 'is unauthorized' do
        put "/v1/users/#{alfred.username}",
            params: { user: valid_attributes }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to match('Unauthorized access')
      end
    end
  end

  describe 'DELETE /v1/users/:username' do
    context 'authenticated user' do
      context 'deleting own account' do
        it 'is successfully processed' do
          delete "/v1/users/#{alfred.username}",
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:accepted)
        end
      end

      context "attempting to delete other user's account" do
        it 'is not successful' do
          delete "/v1/users/#{arnold.username}",
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
    context 'unauthenticated user' do
      it 'is invalid' do
        delete "/v1/users/#{alfred.username}"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to match('Unauthorized access')
      end
    end
  end
end
