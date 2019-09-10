# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendships', type: :request do
  let(:harry) { create(:user, :male, first_name: 'Harry') }
  let(:hermione) { create(:user, :female, first_name: 'Hermione') }
  let(:goku) { create(:user, :male, first_name: 'Goku') }

  describe 'POST /v1/friendships?friend_requested=:username' do
    context 'harry adds hermione as friend' do
      it 'adds to friendships record' do
        login_as(harry)
        expect do
          post "/v1/friendships?friend_requested=#{hermione.username}",
               headers: { "Authorization": "Bearer #{user_token}" }
        end.to change(Friendship, :count).by(1)
      end
    end
  end

  describe 'PUT /v1/friendships/:id' do
    let(:friendship) { create(:friendship, active_friend: hermione, passive_friend: goku) }

    context 'friendship record cannot be found' do
      it 'responds with a 404 error' do
        login_as(goku)
        friendship_id = "#{friendship.id}123"
        put "/v1/friendships/#{friendship_id}",
            headers: {
              "Authorization": "Bearer #{user_token}"
            }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find resource')
      end
    end

    context "goku confirms hermione's friend request" do
      before do
        login_as(goku)

        put "/v1/friendships/#{friendship.id}",
            headers: { "Authorization": "Bearer #{user_token}" }
        friendship.reload
        goku.reload
      end

      it 'sends a success response' do
        expect(response).to have_http_status(:accepted)
      end

      it 'updates friendship.confirmed to true' do
        expect(friendship.confirmed).to be(true)
      end

      it "adds hermione in goku's friends list" do
        expect(goku.friends).to include(hermione)
      end
    end
  end

  describe 'DELETE /v1/friendships/:id' do
    let(:friendship) { create(:friendship, active_friend: harry, passive_friend: goku) }

    context 'Goku accepts friendship but later on deletes it' do
      before do
        login_as(goku)
        friendship.confirm
        delete "/v1/friendships/#{friendship.id}",
               headers: { "Authorization": "Bearer #{user_token}" }
      end
      it 'sends a success response' do
        expect(response).to have_http_status(:accepted)
      end
      it "sends a response with 'Friendship deleted' message" do
        expect(JSON.parse(response.body)['message']).to match('Friendship deleted')
      end
    end

    context 'Goku rejects the friend request' do
      before do
        login_as(goku)
        delete "/v1/friendships/#{friendship.id}",
               headers: { "Authorization": "Bearer #{user_token}" }
      end

      it "sends a response with message 'Rejected friend request'" do
        expect(JSON.parse(response.body)['message']).to match('Rejected friend request')
      end
    end

    context 'Mike cancels the friend request' do
      before do
        login_as(harry)
        delete "/v1/friendships/#{friendship.id}",
               headers: { "Authorization": "Bearer #{user_token}" }
      end

      it "sends a response with message 'Rejected friend request'" do
        expect(JSON.parse(response.body)['message']).to match('Cancelled friend request')
      end
    end
  end
end
