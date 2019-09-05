# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'POST /v1/posts' do
    let(:cleo) { create(:user, username: 'cleo') }
    let(:julius) { create(:user, username: 'julius') }

    before do
      login_as(julius)
    end

    context 'user to post to exists' do
      context 'content is present' do
        it 'sends the post created as response' do
          content = 'Some content'
          post '/v1/posts',
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { post: {
                 postable: cleo.username,
                 content: content
               } }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response.keys)
            .to match(%w[id author author_url posted_to postable_url content created_at updated_at])
          expect(json_response['content']).to eq(content)
          expect(json_response['posted_to']).to eq(cleo.username)
        end
      end

      context 'content left blank' do
        it 'sends an error response message' do
          post '/v1/posts',
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { post: {
                 postable: cleo.username,
                 content: nil
               } }

          json_response = JSON.parse(response.body)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['message']).to match('Cannot create post')
          expect(json_response['errors']['content']).to match(["can't be blank"])
        end
      end
    end

    context 'postable user does not exist' do
      it 'responds with an error json' do
        post '/v1/posts',
             headers: { "Authorization": "Bearer #{user_token}" },
             params: { post: {
               postable: 'nick',
               content: nil
             } }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to eq('User does not exist')
      end
    end
  end
end
