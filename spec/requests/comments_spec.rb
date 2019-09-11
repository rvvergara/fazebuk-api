# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:bart) { create(:user, :male, first_name: 'Bart') }
  let(:lisa) { create(:user, :female, first_name: 'Lisa') }
  let!(:post_to_lisa) { create(:post, author: bart, postable: lisa) }
  let!(:comment) { create(:comment, :for_post, commenter: lisa, commentable: post_to_lisa) }
  let!(:reply) { create(:reply, :for_comment, commenter: bart, commentable: comment) }
  let!(:updated_body) { 'Updated body' }

  describe 'unauthenticated user requests' do
    it {
      post "/v1/posts/#{post_to_lisa.id}/comments"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      post "/v1/comments/#{comment.id}/replies"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put "/v1/comments/#{comment.id}"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put "/v1/comments/#{reply.id}"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/comments/#{comment.id}"

      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete "/v1/comments/#{reply.id}"

      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'POST /v1/posts/:post_id/comments' do
    let!(:login) { login_as(lisa) }

    context 'post exists' do
      context 'valid params' do
        it 'saves to the database' do
          expect do
            post "/v1/posts/#{post_to_lisa.id}/comments",
                 headers: { "Authorization": "Bearer #{user_token}" },
                 params: { comment: attributes_for(:comment, :for_post) }
          end
            .to change(Comment, :count).by(1)
        end

        it 'sends created comment as response' do
          post "/v1/posts/#{post_to_lisa.id}/comments",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { comment: attributes_for(:comment, :for_post) }

          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(
            %w[id commenter body created_at updated_at replies likes liked? like_id]
          )
          expect(json_response['commenter']['username']).to eq(lisa.username)
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          post "/v1/posts/#{post_to_lisa.id}/comments",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { comment: attributes_for(:comment, :invalid, :for_post) }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        post '/v1/posts/nonExistentPostId/comments',
             headers: { "Authorization": "Bearer #{user_token}" },
             params: { comment: attributes_for(:comment, :for_post) }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/replies' do
    let!(:login) { login_as(bart) }

    context 'comment exists' do
      context 'valid params' do
        it 'saves to the database' do
          expect do
            post "/v1/comments/#{comment.id}/replies",
                 headers: { "Authorization": "Bearer #{user_token}" },
                 params: { reply: attributes_for(:reply, :for_comment) }
          end
            .to change(Comment, :count).by(1)
        end

        it 'sends created reply as response' do
          post "/v1/comments/#{comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(:reply, :for_comment) }

          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(
            %w[id commenter body created_at updated_at likes liked? like_id]
          )
          expect(json_response['commenter']['username']).to eq(bart.username)
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          post "/v1/comments/#{comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(:reply, :invalid, :for_comment) }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        post '/v1/comments/nonExistentPostId/replies',
             headers: { "Authorization": "Bearer #{user_token}" },
             params: { reply: attributes_for(:reply, :for_comment) }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'PUT /v1/comments/:id' do
    let!(:login) { login_as(bart) }
    context 'comment exists' do
      context 'valid params' do
        let!(:update) do
          put "/v1/comments/#{reply.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { comment: { body: updated_body } }

          reply.reload
        end

        it 'updates the body of reply' do
          expect(reply.body).to match(updated_body)
        end

        it 'sends updated reply as response' do
          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:accepted)
          expect(json_response['body']).to match(updated_body)
        end
      end

      context 'invalid params' do
        let!(:update) do
          put "/v1/comments/#{reply.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { comment: attributes_for(:reply, :for_comment, :invalid) }

          reply.reload
        end

        it 'does not change reply body' do
          expect(reply.body).to_not eq(updated_body)
        end

        it 'sends an error response' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        put '/v1/comments/nonExistentCommentId',
            headers: { "Authorization": "Bearer #{user_token}" },
            params: { comment: attributes_for(:reply, :for_comment) }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'DELETE /v1/comments/:id' do
    let!(:login) { login_as(lisa) }

    context 'comment exists' do
      it 'removes comment (and replies) from db' do
        expect do
          delete "/v1/comments/#{comment.id}",
                 headers: { "Authorization": "Bearer #{user_token}" }
        end
          .to change(Comment, :count).by(-2)
      end

      it 'sends a success response' do
        delete "/v1/comments/#{comment.id}",
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['message']).to match('Comment deleted')
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        delete '/v1/comments/nonExistingCommentId',
               headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
      end
    end
  end
end
