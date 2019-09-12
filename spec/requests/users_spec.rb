# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:alfred) { create(:user, :male, first_name: 'Alfred') }
  let(:conrad) { create(:user, :male, first_name: 'Conrad') }
  let!(:friendship) { create(:friendship, :confirmed, active_friend: alfred, passive_friend: conrad) }
  let!(:login) { login_as(alfred) }

  describe 'unauthenticated user requests' do
    it {
      get "/v1/users/#{alfred.username}"
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put "/v1/users/#{alfred.username}"
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/users/#{alfred.username}"
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/users/:username' do
    context 'user exists' do
      it 'sends the user data as response' do
        get user_route(conrad.username),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(user_response_keys)
        expect(json_response['is_already_a_friend?']).to be(true)
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        get user_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end

  describe 'POST /v1/users' do
    context 'valid params' do
      it 'creates & authenticates user' do
        expect do
          post user_route(nil),
               params: user_params(valid_user_attributes)
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        expect(json_response['user']['token']).to eq(user_token)
      end
    end

    context 'invalid params' do
      context 'missing first_name' do
        it 'does not create a user' do
          expect do
            post user_route(nil),
                 params: user_params(invalid_user_attributes)
          end.to_not change(User, :count)

          expect(json_response['message']).to match('Cannot create user')
        end
      end

      context 'duplicate username' do
        it 'does not create user' do
          expect do
            post user_route(nil),
                 params: user_params(valid_user_attributes.merge(username: conrad.username))
          end
            .to_not change(User, :count)

          expect(json_response['errors']['username']).to include('has already been taken')
        end
      end
    end
  end

  describe 'PUT /v1/users/:username' do
    let!(:login) { login_as(alfred) }

    context 'user exists' do
      context 'valid params' do
        before { update_user(alfred.username, first_name: 'King') }

        it 'changes user record' do
          alfred.reload
          expect(alfred.first_name).to eq('King')
        end

        it 'sends updated user data as response' do
          expect(response).to have_http_status(:accepted)
          expect(json_response.keys).to match(user_response_keys)
          expect(json_response['first_name']).to eq('King')
        end
      end

      context 'invalid params' do
        context 'missing first name' do
          before { update_user(alfred.username, invalid_user_attributes) }

          it 'does not update user record' do
            alfred.reload
            expect(alfred.first_name).to eq('Alfred')
          end

          it 'sends an error response' do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']['first_name']).to include("can't be blank")
          end
        end

        context 'duplicate username' do
          before { update_user(alfred.username, username: conrad.username) }

          it 'does not change user record' do
            alfred.reload

            expect(alfred.username).to eq('alfred')
          end
        end
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        put user_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end

  describe 'DELETE /v1/users/:username' do
    context 'user exists' do
      it 'removes user record from the db' do
        expect do
          delete user_route(alfred.username),
                 headers: authorization_header
        end
          .to change(User, :count).by(-1)
      end

      it 'sends a success response' do
        delete user_route(alfred.username),
               headers: authorization_header

        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Account deleted')
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        delete user_route('nobody'),
               headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end
end
