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

  describe 'PUT /v1/users/:username' do
    let(:lebron) { create(:user, username: 'lebron') }
    let(:boogie) { create(:user, username: 'boogie', first_name: 'Demarcus') }

    before { login_as(lebron) }

    context 'lebron updating his own account' do
      it 'is accepted' do
        put "/v1/users/#{lebron.username}",
            headers: { "Authorization": "Bearer #{user_token}" },
            params: { user: { first_name: 'King' } }
        lebron.reload
        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['user']['data']['first_name']).to eq('King')
        expect(lebron.first_name).to eq('King')
      end
    end

    context "lebron attempting to update boogie's account" do
      it 'is unauthorized' do
        put "/v1/users/#{boogie.username}",
            headers: { "Authorization": "Bearer #{user_token}" },
            params: { user: { first_name: 'Booger' } }

        expect(response).to have_http_status(:unauthorized)
        boogie.reload
        expect(boogie.first_name).to eq('Demarcus')
      end
    end
  end

  describe 'DELETE /v1/users/:username' do
    let(:cesar) { create(:user, username: 'cesar') }
    let(:pompey) { create(:user, username: 'pompey') }

    before { login_as(cesar) }

    context 'cesar deleting his own account' do
      it 'is successfully processed' do
        delete "/v1/users/#{cesar.username}",
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:accepted)
      end
    end

    context "cesar deleting pompey's account" do
      it 'is not successful' do
        delete "/v1/users/#{pompey.username}",
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
