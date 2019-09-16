# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendships', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let(:ron) { create(:user, :male, first_name: 'Ron') }
  let(:hermione) { create(:user, :female, first_name: 'Hermione') }
  let!(:ron_hermione_friendship) { create(:friendship, :confirmed, active_friend: hermione, passive_friend: ron) }
  let!(:harry_ron_request) { create(:request, active_friend: harry, passive_friend: ron) }

  describe 'unauthenticated users request' do
    it {
      post friend_request_route(ron.username)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put friendship_route(harry_ron_request.id)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete friendship_route(ron_hermione_friendship.id)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete friendship_route(harry_ron_request.id)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'POST /v1/friendships' do
    let!(:login) { login_as(harry) }

    context 'valid request' do
      subject do
        post friend_request_route(hermione.username),
             headers: authorization_header
      end

      it 'adds friendship record to the db' do
        expect { subject }.to change(Friendship, :count).by(1)
      end

      it 'sends passive_friend data as response' do
        subject
        expect(response).to have_http_status(:created)
        expect(json_response['sent_request_to'].keys).to match(user_response_keys)
        expect(json_response['sent_request_to']['username']).to eq(hermione.username)
      end
    end

    context 'invalid requests' do
      context 'requested user does not exist' do
        it 'sends an error response' do
          post friend_request_route('norman'),
               headers: authorization_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['message']).to match('Cannot send request')
          expect(json_response['errors']['passive_friend']).to include('must exist')
        end
      end

      context 'duplicate friend request' do
        it 'does not add to the db record' do
          expect do
            post friend_request_route(ron.username),
                 headers: authorization_header
          end
            .to_not change(Friendship, :count)
        end

        it 'sends an error response' do
          post friend_request_route(ron.username),
               headers: authorization_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['combined_ids']).to include('has already been taken')
        end
      end

      context 'request sent to existing friend' do
        let!(:accept) { harry_ron_request.confirm }

        it 'does not create friendship record' do
          expect do
            post friend_request_route(ron.username),
                 headers: authorization_header
          end
            .to_not change(Friendship, :count)
        end
        it 'sends an error response' do
          post friend_request_route(ron.username),
               headers: authorization_header

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['combined_ids']).to include('has already been taken')
        end
      end
    end
  end

  describe 'PUT /v1/friendships/:id' do
    let!(:login) { login_as(ron) }

    context 'friendship exists' do
      subject! do
        put friendship_route(harry_ron_request.id),
            headers: authorization_header
      end

      it 'changes friendship record in the db' do
        harry_ron_request.reload
        expect(harry_ron_request.confirmed).to be(true)
      end

      it 'sends a success message' do
        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Friend request confirmed!')
      end
    end

    context 'friendship does not exist' do
      it 'sends an error response' do
        put friendship_route('nonExistentFriendshipId'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find friendship or request')
      end
    end
  end

  describe 'DESTROY /v1/friendships/:id' do
    context 'friendship exists' do
      context 'request to delete friendship' do
        subject do
          login_as(hermione)
          delete friendship_route(ron_hermione_friendship.id),
                 headers: authorization_header
        end
        it 'removes friendship record from db' do
          expect { subject }.to change(Friendship, :count).by(-1)
        end

        it 'sends a success response' do
          subject
          expect(response).to have_http_status(:accepted)
          expect(json_response['message']).to match('Friendship deleted')
        end
      end

      context 'request to cancel request' do
        it 'sends a cancelled request message' do
          login_as(harry)
          delete friendship_route(harry_ron_request.id),
                 headers: authorization_header

          expect(json_response['message']).to match('Cancelled friend request')
        end
      end

      context 'request to reject request' do
        it 'sends a rejected request message' do
          login_as(ron)
          delete friendship_route(harry_ron_request.id),
                 headers: authorization_header

          expect(json_response['message']).to match('Rejected friend request')
        end
      end
    end

    context 'friendship does not exist' do
      let!(:login) { login_as(harry) }

      it 'sends an error response' do
        delete friendship_route('wrongFriendshipId'),
               headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find friendship or request')
      end
    end
  end
end
