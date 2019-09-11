# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendships', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let(:hermione) { create(:user, :female, first_name: 'Hermione') }
  let(:goku) { create(:user, :male, first_name: 'Goku') }
  let!(:harry_to_goku_request) { create(:request, active_friend: harry, passive_friend: goku) }

  describe 'POST /v1/friendships' do
    context 'authenticated user' do
      let!(:login) { login_as(harry) }

      context 'valid params' do
        it 'adds to Friendship db record' do
          expect do
            post "/v1/friendships?friend_requested=#{hermione.username}",
                 headers: { "Authorization": "Bearer #{user_token}" }
          end
            .to change(Friendship, :count)
        end
        it 'sends a success response' do
          post "/v1/friendships?friend_requested=#{hermione.username}",
               headers: { "Authorization": "Bearer #{user_token}" }

          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:created)

          expect(json_response['message']).to match('Successfully requested friendship')

          expect(json_response.keys)
            .to match(%w[message sent_request_to])

          expect(json_response['sent_request_to']['username']).to match(hermione.username)
        end
      end

      context 'invalid or missing params' do
        it 'does not add to database' do
          expect do
            post '/v1/friendships?friend_requested=noel',
                 headers: { "Authorization": "Bearer #{user_token}" }
          end
            .to_not change(Friendship, :count)
        end

        it 'sends an error response' do
          post '/v1/friendships?friend_requested=noel',
               headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['passive_friend']).to include('must exist')
        end
      end
    end

    context 'unauthenticated user' do
      it 'is unauthorized' do
        post "/v1/friendships?friend_requested=#{hermione.username}"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to match('Unauthorized access')
      end
    end
  end

  describe 'PUT /v1/friendships/:id' do
    context 'authenticated user' do
      context 'friendship record exists' do
        let!(:accept) do
          login_as(goku)

          put "/v1/friendships/#{harry_to_goku_request.id}",
              headers: { "Authorization": "Bearer #{user_token}" }
        end

        it 'updates the friendship to confirmed status' do
          harry_to_goku_request.reload
          expect(harry_to_goku_request.confirmed).to be(true)
        end

        it 'sends a success json response' do
          expect(response).to have_http_status(:accepted)
          expect(JSON.parse(response.body)['message']).to match('Friend request confirmed!')
        end
      end

      context 'friendship record does not exist' do
        it 'sends an error response' do
          login_as(goku)

          put '/v1/friendships/nonExistentFriendshipId',
              headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)['message']).to match('Cannot find resource')
        end
      end
    end

    context 'unauthenticated user' do
      it 'is unauthorized' do
        put "/v1/friendships/#{harry_to_goku_request.id}"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to match('Unauthorized access')
      end
    end
  end

  describe 'DELETE /v1/friendships/:id' do
    context 'authenticated user' do
      context 'friendship record exists' do
        context 'deleting a confirmed friendship' do
          let!(:confirm_n_login) do
            harry_to_goku_request.confirm
            harry_to_goku_request.reload
            login_as(goku)
          end

          it 'removes record from db' do
            expect do
              delete "/v1/friendships/#{harry_to_goku_request.id}",
                     headers: { "Authorization": "Bearer #{user_token}" }
            end
              .to change(Friendship, :count).by(-1)
          end

          it 'sends a success response' do
            delete "/v1/friendships/#{harry_to_goku_request.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }

            expect(response).to have_http_status(:accepted)
            expect(JSON.parse(response.body)['message']).to match('Friendship deleted')
          end
        end

        context 'rejecting a friend request' do
          let!(:login) { login_as(goku) }
          it 'removes friendship record from db' do
            expect do
              delete "/v1/friendships/#{harry_to_goku_request.id}",
                     headers: { "Authorization": "Bearer #{user_token}" }
            end.to change(Friendship, :count).by(-1)
          end

          it 'sends a success response' do
            delete "/v1/friendships/#{harry_to_goku_request.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }

            expect(response).to have_http_status(:accepted)
            expect(JSON.parse(response.body)['message']).to match('Rejected friend request')
          end
        end

        context 'cancelling a friend request' do
          let!(:login) { login_as(harry) }

          it 'removes friendship record from db' do
            expect do
              delete "/v1/friendships/#{harry_to_goku_request.id}",
                     headers: { "Authorization": "Bearer #{user_token}" }
            end
              .to change(Friendship, :count).by(-1)
          end

          it 'sends a success response' do
            delete "/v1/friendships/#{harry_to_goku_request.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }

            expect(response).to have_http_status(:accepted)
            expect(JSON.parse(response.body)['message']).to match('Cancelled friend request')
          end
        end
      end

      context 'friendship record does not exist' do
      end
    end

    context 'unauthenticated user' do
      it 'is unauthorized' do
        delete "/v1/friendships/#{harry_to_goku_request.id}"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to match('Unauthorized access')
      end
    end
  end
end
