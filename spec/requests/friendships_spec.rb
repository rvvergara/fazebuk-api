# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Friendships', type: :request do
  let(:harry) { create(:user, username: 'harry') }
  let(:hermione) { create(:user, username: 'hermione') }
  let(:goku) { create(:user, username: 'goku') }

  describe 'GET /v1/users/:user_username/friends' do
    before do
      [harry, hermione].each do |friend|
        create(:friendship, active_friend: goku, passive_friend: friend, confirmed: true)
      end
    end
    context 'goku logs on to check his friends' do
      it 'gives him an array of json data of his friends' do
        login_as(goku)
        get "/v1/users/#{goku.username}/friends",
            headers: { "Authorization": "Bearer #{user_token}" }

        expect(JSON.parse(response.body).size).to be(2)
        expect(response).to have_http_status(:ok)
      end
    end
  end

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
