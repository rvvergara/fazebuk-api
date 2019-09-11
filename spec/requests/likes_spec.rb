# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let(:steve) { create(:user, :male, first_name: 'Steve') }
  let(:seth) { create(:user, :male, first_name: 'Seth') }
  let(:stalker) { create(:user, :female, first_name: 'Becky') }
  let(:post_to_seth) { create(:post, author: steve, postable: seth) }
  let(:comment_to_post) { create(:comment, :for_post, commenter: seth, commentable: post_to_seth) }
  let!(:post_like) { create(:like, :for_post, likeable: post_to_seth, liker: seth) }
  let!(:comment_like) { create(:like, :for_comment, likeable: comment_to_post, liker: steve) }

  describe 'unauthenticated user requests' do
    it {
      post "/v1/posts/#{post_to_seth.id}/likes"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      post "/v1/comments/#{comment_to_post.id}/likes"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/likes/#{post_like.id}"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/likes/#{comment_like.id}"

      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'POST /v1/posts/:id/likes' do
    let!(:login) { login_as(stalker) }

    context 'post exists' do
      context 'valid params' do
        it 'adds like to the database' do
          expect do
            post "/v1/posts/#{post_to_seth.id}/likes",
                 headers: { "Authorization": "Bearer #{user_token}" }
          end
            .to change(Like, :count).by(1)
        end

        it 'sends a success message' do
          post "/v1/posts/#{post_to_seth.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['message']).to match('Successfully liked post')
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          login_as(seth)
          post "/v1/posts/#{post_to_seth.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['liker']).to include('cannot like the post twice')
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        post '/v1/posts/nonExistentPostId/likes',
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:id/likes' do
    let!(:login) { login_as(stalker) }

    context 'comment exists' do
      context 'valid params' do
        it 'adds like to the database' do
          expect do
            post "/v1/comments/#{comment_to_post.id}/likes",
                 headers: { "Authorization": "Bearer #{user_token}" }
          end
            .to change(Like, :count).by(1)
        end

        it 'sends a success response' do
          post "/v1/comments/#{comment_to_post.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['message']).to match('Successfully liked comment')
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          login_as(steve)

          post "/v1/comments/#{comment_to_post.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['liker']).to include('cannot like the comment twice')
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        post '/v1/comments/someNonExistenCommentId/likes',
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
      end
    end
  end
end
