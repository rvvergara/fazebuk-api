# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:beng) { create(:user, :female, first_name: 'Beng') }
  let(:karen) { create(:user, :female, first_name: 'Karen') }
  let!(:post_to_karen) { create(:post, author: beng, postable: karen) }
  let(:updated_content) { 'Updated content' }
  let!(:login) { login_as(beng) }

  describe 'requests by unauthenticated user' do
    it {
      get "/v1/posts/#{post_to_karen.id}"
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      post "/v1/posts?postable=#{karen.username}"
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put "/v1/posts/#{post_to_karen.id}"
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/posts/#{post_to_karen.id}"
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/posts/:id' do
    context 'post exists' do
      let!(:visit) do
        get "/v1/posts/#{post_to_karen.id}",
            headers: { "Authorization": "Bearer #{user_token}" }
      end

      it 'sends a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'sends the json data of post' do
        json_response = JSON.parse(response.body)
        expect(json_response.keys)
          .to match(%w[id content created_at updated_at author posted_to comments likes liked? like_id])

        expect(json_response['posted_to']['username']).to eq(karen.username)
        expect(json_response['author']['username']).to eq(beng.username)
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        get '/v1/posts/nonExistentPostId',
            headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Post does not exist')
      end
    end
  end

  describe 'POST /v1/posts' do
    context 'complete and valid post params' do
      it 'adds post to the database' do
        expect do
          post '/v1/posts',
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { post: attributes_for(:post).merge(postable: beng.username) }
        end
          .to change(Post, :count).by(1)
      end

      it 'responds w/ data of created post' do
        post '/v1/posts',
             headers: { "Authorization": "Bearer #{user_token}" },
             params: { post: attributes_for(:post).merge(postable: beng.username) }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(json_response.keys).to match(
          %w[id content created_at updated_at author posted_to comments likes liked? like_id]
        )
        expect(json_response['author']['username']).to eq(beng.username)
        expect(json_response['posted_to']['username']).to eq(beng.username)
      end
    end

    context 'incomplete or invalid post params' do
      it 'sends an error response' do
        post '/v1/posts',
             headers: { "Authorization": "Bearer #{user_token}" },
             params: { post: attributes_for(:post, :invalid).merge(postable: karen.username) }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['message']).to match('Cannot create post')
        expect(json_response['errors']['content']).to include("can't be blank")
      end
    end
  end

  describe 'PUT /v1/posts/:id' do
    context 'post exists' do
      context 'valid post params' do
        let!(:update) do
          put "/v1/posts/#{post_to_karen.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { post: { content: updated_content, postable: karen.username } }

          post_to_karen.reload
        end

        it 'updates the post on the db' do
          expect(post_to_karen.content).to eq(updated_content)
        end

        it 'sends the updated post as response' do
          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:accepted)

          expect(json_response['content']).to match(updated_content)
        end
      end

      context 'invalid post params' do
        let!(:update) do
          put "/v1/posts/#{post_to_karen.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { post: attributes_for(:post).merge(content: updated_content) }

          post_to_karen.reload
        end

        it 'does not change post in the db' do
          expect(post_to_karen.content).to_not eq(updated_content)
        end

        it 'sends error response' do
          json_response = JSON.parse(response.body)

          expect(json_response['errors']['postable']).to include('must exist')
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        put '/v1/posts/nonExistentPostId',
            headers: { "Authorization": "Bearer #{user_token}" },
            params: { post: attributes_for(:post).merge(postable: beng) }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Post does not exist')
      end
    end
  end

  describe 'DELETE /v1/posts/:id' do
    context 'post exists' do
      it 'removes post from db' do
        expect do
          delete "/v1/posts/#{post_to_karen.id}",
                 headers: { "Authorization": "Bearer #{user_token}" }
        end
          .to change(Post, :count).by(-1)
      end

      it 'sends a success response' do
        delete "/v1/posts/#{post_to_karen.id}",
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['message']).to match('Post deleted')
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        delete '/v1/posts/nonExistentPosId',
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Post does not exist')
      end
    end
  end
end
