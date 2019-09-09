# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /v1/posts/:id' do
    let(:colt) { create(:male_user, username: 'colt') }
    let(:andrew) { create(:male_user, username: 'andrew') }

    before do
      @post = create(:post, author: colt, postable: andrew)
      login_as(andrew)
    end

    context 'visiting an existing post' do
      it 'sends the post as json response' do
        get "/v1/posts/#{@post.id}",
            headers: { "Authorization": "Bearer #{user_token}" }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(
          %w[id content created_at updated_at author posted_to comments]
        )
        expect(json_response['content']).to match(@post.content)
      end
    end

    context 'visiting a post that does not exist' do
      it 'sends an error json response' do
        get '/v1/posts/someIdOfNonExistentPost',
            headers: { "Authorization": "Bearer #{user_token}" }

        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Post does not exist')
      end
    end
  end

  describe 'POST /v1/posts' do
    let(:cleo) { create(:female_user, username: 'cleo') }
    let(:julius) { create(:male_user, username: 'julius') }

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
            .to match(%w[id content created_at updated_at author posted_to comments])
          expect(json_response['content']).to eq(content)
          expect(json_response['posted_to']['username']).to eq(cleo.username)
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
        expect(response).to have_http_status(422)
        expect(json_response['errors']['postable']).to include('must exist')
      end
    end
  end

  describe 'PUT /v1/posts/:id' do
    let(:ragnar) { create(:male_user, username: 'ragnar') }
    let(:bjorn) { create(:male_user, username: 'bjorn') }

    before do
      @post = create(:post, author: ragnar, postable: bjorn)
      login_as(ragnar)
    end

    context 'post and postable exist' do
      context 'content is present' do
        it 'sends the updated post as json response' do
          content = 'Updated content'
          put "/v1/posts/#{@post.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { post: {
                postable: bjorn.username,
                content: content
              } }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:accepted)
          expect(json_response.keys)
            .to match(%w[id content created_at updated_at author posted_to comments])
          expect(json_response['content']).to eq(content)
          expect(json_response['posted_to']['username']).to eq(bjorn.username)
        end
      end

      context 'content is missing' do
        it 'sends an error json' do
          put "/v1/posts/#{@post.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: { post: {
                postable: bjorn.username,
                content: nil
              } }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['message']).to match('Cannot update post')
          expect(json_response['errors']['content'].first).to match("can't be blank")
        end
      end
    end

    context 'post or postable does not exist' do
      context 'postable does not exist' do
        it 'sends an error response' do
          put "/v1/posts/#{@post.id}",
              headers: { "Authorization": "Bearer #{user_token}" },
              params: {
                post: {
                  postable: 'arnold',
                  content: 'Updated content'
                }
              }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(422)
          expect(json_response['errors']['postable']).to include('must exist')
        end
      end

      context 'post does not exist' do
        it 'sends an error response' do
          put '/v1/posts/another233id',
              headers: { "Authorization": "Bearer #{user_token}" },
              params: {
                post: {
                  postable: bjorn,
                  content: 'Updated content'
                }
              }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(404)
          expect(json_response['message']).to match('Post does not exist')
        end
      end
    end
  end

  describe 'DELETE /v1/posts/:id' do
    let(:harvey) { create(:male_user) }
    let(:louis) { create(:male_user) }

    before do
      login_as(harvey)
    end

    context 'post exists' do
      it 'sends a success json response' do
        post = create(:post, author: harvey, postable: louis)

        delete "/v1/posts/#{post.id}",
               headers: { "Authorization": "Bearer #{user_token}" }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(202)
        expect(json_response['message']).to match('Post deleted')
      end
    end

    context 'post does not exist' do
      it 'sends an error json response' do
        delete '/v1/posts/123someId',
               headers: { "Authorization": "Bearer #{user_token}" }

        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Post does not exist')
      end
    end
  end
end
