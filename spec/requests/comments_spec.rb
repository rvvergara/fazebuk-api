# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:laura) { create(:user) }
  let(:dominic) { create(:user) }

  before do
    @post = create(:post, author: laura, postable: dominic)
  end

  describe 'POST /v1/posts/:post_id/comments' do
    before do
      login_as(dominic)
    end

    context 'post exists' do
      context 'comment body present' do
        it 'sends the created comment as json response' do
          post "/v1/posts/#{@post.id}/comments",
               headers: {
                 "Authorization": "Bearer #{user_token}"
               },
               params: {
                 comment: attributes_for(:post_comment, commenter: dominic)
               }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(%w[id commenter commenter_url body created_at updated_at])
          expect(json_response['commenter']).to eq(dominic.username)
        end
      end

      context 'comment body is missing' do
        it 'sends an error json response' do
          post "/v1/posts/#{@post.id}/comments",
               headers: {
                 "Authorization": "Bearer #{user_token}"
               },
               params: {
                 comment: attributes_for(:post_comment, commenter: dominic, body: nil)
               }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['message']).to match('Cannot create comment')
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        post '/v1/posts/eff122someId/comments',
             headers: {
               "Authorization": "Bearer #{user_token}"
             },
             params: {
               comment: attributes_for(:post_comment, commenter: dominic)
             }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/replies' do
    before do
      @comment = create(:post_comment, commenter: dominic, commentable: @post)
      login_as(laura)
    end

    context 'comment exists' do
      context 'reply body is present' do
        it 'sends the reply as json response' do
          post "/v1/comments/#{@comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(:comment_reply, commenter: laura, commentable: @comment) }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(%w[id commenter commenter_url body created_at updated_at])
          expect(json_response['commenter']).to eq(laura.username)
        end
      end

      context 'reply body is missing' do
        it 'sends an error response' do
          post "/v1/comments/#{@comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(:comment_reply, commenter: laura, commentable: @comment, body: nil) }

          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['message']).to match('Cannot create comment')
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        post '/v1/comments/eff122someId/replies',
             headers: {
               "Authorization": "Bearer #{user_token}"
             },
             params: {
               comment: attributes_for(:comment_reply, commenter: laura)
             }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end
end
