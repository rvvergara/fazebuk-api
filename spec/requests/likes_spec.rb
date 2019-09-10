# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let(:steve) { create(:user, :male, first_name: 'Steve') }
  let(:seth) { create(:user, :male, first_name: 'Seth') }

  let!(:login) do
    login_as(seth)

    @post = create(:post, author: steve, postable: seth)
  end

  describe 'POST /v1/posts/:post_id/likes' do
    context 'post exists' do
      it 'adds like to the database' do
        expect do
          post "/v1/posts/#{@post.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }
        end.to change(Like, :count).by(1)
      end

      it 'sends a success json response' do
        post "/v1/posts/#{@post.id}/likes",
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to include('Successfully liked post')
      end
    end

    context 'post does not exist' do
      it 'responds with an error json' do
        post '/v1/posts/nonExistentPostId/likes',
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']['likeable']).to include('must exist')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/likes' do
    let(:comment) { create(:comment, :for_post, commenter: steve, commentable: @post) }
    let(:reply) { create(:reply, :for_comment, commenter: steve, commentable: comment) }

    context 'comment exists' do
      it 'adds like to the database' do
        expect do
          post "/v1/comments/#{comment.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }
        end.to change(Like, :count).by(1)

        expect do
          login_as(seth)
          post "/v1/comments/#{reply.id}/likes",
               headers: { "Authorization": "Bearer #{user_token}" }
        end.to change(Like, :count).by(1)
      end

      it 'sends a success JSON response' do
        post "/v1/comments/#{comment.id}/likes",
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to match('Successfully liked comment')
      end
    end

    context 'comment/reply does not exist' do
      it 'sends an error json response' do
        post '/v1/comments/nonExistenCommentId/likes',
             headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']['likeable']).to include('must exist')
      end
    end
  end

  describe 'DELETE /v1/likes/:id' do
    context 'post likes' do
      let!(:like) { create(:like, :for_post, likeable: @post, liker: seth) }

      context 'like record exists' do
        it 'removes like from the database' do
          expect do
            delete "/v1/likes/#{like.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }
          end.to change(Like, :count).by(-1)
        end

        it 'sends a success json response' do
          delete "/v1/likes/#{like.id}",
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:accepted)
          expect(JSON.parse(response.body)['message']).to match('Unliked post')
        end
      end

      context 'like does not exist' do
        it 'sends an error json response' do
          delete '/v1/likes/nonExistenLikeId',
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)['message']).to match('Cannot find like record')
        end
      end
    end

    context 'comments/replies likes' do
      let(:comment) { create(:comment, :for_post, commenter: steve, commentable: @post) }
      let!(:like) { create(:like, :for_comment, likeable: comment, liker: seth) }

      context 'like record exists' do
        it 'removes like from the database' do
          expect do
            delete "/v1/likes/#{like.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }
          end.to change(Like, :count).by(-1)
        end

        it 'sends a success json response' do
          delete "/v1/likes/#{like.id}",
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(:accepted)
          expect(JSON.parse(response.body)['message']).to match('Unliked comment')
        end
      end

      context 'like does not exist' do
        it 'sends an error json response' do
          delete '/v1/likes/nonExistenLikeId',
                 headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)['message']).to match('Cannot find like record')
        end
      end
    end
  end
end
