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
            post post_comments_route(post_to_lisa.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:comment)
          end
            .to change(Comment, :count).by(1)
        end

        it 'sends created comment as response' do
          post post_comments_route(post_to_lisa.id),
               headers: authorization_header,
               params: valid_comment_attributes(:comment)

          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(comment_response_keys)
          expect(json_response['commenter']['username']).to eq(lisa.username)
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          post post_comments_route(post_to_lisa.id),
               headers: authorization_header,
               params: invalid_comment_attributes(:comment, :for_post)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        post post_comments_route('nonExistentPostId'),
             headers: authorization_header,
             params: { comment: attributes_for(:comment, :for_post) }

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/replies' do
    let!(:login) { login_as(bart) }

    context 'comment exists' do
      context 'valid params' do
        it 'saves to the database' do
          expect do
            post comment_replies_route(comment.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:reply)
          end
            .to change(Comment, :count).by(1)
        end

        it 'sends created reply as response' do
          post comment_replies_route(comment.id),
               headers: authorization_header,
               params: valid_comment_attributes('reply')

          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(comment_reply_response_keys)
          expect(json_response['commenter']['username']).to eq(bart.username)
        end
      end

      context 'invalid params' do
        it 'sends an error response' do
          post comment_replies_route(comment.id),
               headers: authorization_header,
               params: invalid_comment_attributes(:reply, :for_comment)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        post comment_replies_route('nonExistentCommentId'),
             headers: authorization_header,
             params: valid_comment_attributes(:reply)

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'PUT /v1/comments/:id' do
    let!(:login) { login_as(bart) }
    context 'comment exists' do
      context 'valid params' do
        let!(:update) do
          put comment_route(reply.id),
              headers: authorization_header,
              params: valid_comment_attributes('comment', body: updated_body)

          reply.reload
        end

        it 'updates the body of reply' do
          expect(reply.body).to match(updated_body)
        end

        it 'sends updated reply as response' do
          expect(response).to have_http_status(:accepted)
          expect(json_response['body']).to match(updated_body)
        end
      end

      context 'invalid params' do
        let!(:update) do
          put comment_route(reply.id),
              headers: authorization_header,
              params: invalid_comment_attributes(:reply, :for_comment, :comment)

          reply.reload
        end

        it 'does not change reply body' do
          expect(reply.body).to_not eq(updated_body)
        end

        it 'sends an error response' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        put comment_route('nonExistentCommentId'),
            headers: authorization_header,
            params: valid_comment_attributes(:reply)

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'DELETE /v1/comments/:id' do
    let!(:login) { login_as(lisa) }

    context 'comment exists' do
      it 'removes comment (and replies) from db' do
        expect do
          delete comment_route(comment.id),
                 headers: authorization_header
        end
          .to change(Comment, :count).by(-2)
      end

      it 'sends a success response' do
        delete comment_route(comment.id),
               headers: authorization_header

        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Comment deleted')
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        delete comment_route('nonExistentCommentId'),
               headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end
end
