# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:laura) { create(:user, :male, first_name: 'Laura') }
  let(:dominic) { create(:user, :male, first_name: 'Dominic') }

  before do
    @post = create(:post, author: laura, postable: dominic)
  end

  describe 'POST /v1/posts/:post_id/comments' do
    before do
      login_as(dominic)
    end

    context 'post exists' do
      context 'comment body present' do
        it 'adds comment to the database' do
          expect do
            post "/v1/posts/#{@post.id}/comments",
                 headers: {
                   "Authorization": "Bearer #{user_token}"
                 },
                 params: {
                   comment: attributes_for(:comment, :for_post, commenter: dominic)
                 }
          end.to change(Comment, :count).by(1)
        end

        it 'sends the created comment as json response' do
          post "/v1/posts/#{@post.id}/comments",
               headers: {
                 "Authorization": "Bearer #{user_token}"
               },
               params: {
                 comment: attributes_for(:comment, :for_post, commenter: dominic)
               }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(%w[id commenter body created_at updated_at replies likes liked? like_id])
          expect(json_response['commenter']['username']).to eq(dominic.username)
        end
      end

      context 'comment body is missing' do
        it 'sends an error json response' do
          post "/v1/posts/#{@post.id}/comments",
               headers: {
                 "Authorization": "Bearer #{user_token}"
               },
               params: {
                 comment: attributes_for(:comment, :for_post, commenter: dominic, body: nil)
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
               comment: attributes_for(:comment, :for_post, commenter: dominic)
             }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/replies' do
    before do
      @comment = create(:comment, :for_post, commenter: dominic, commentable: @post)
      login_as(laura)
    end

    context 'comment exists' do
      context 'reply body is present' do
        it 'adds reply to the database' do
          expect do
            post "/v1/comments/#{@comment.id}/replies",
                 headers: { "Authorization": "Bearer #{user_token}" },
                 params: { reply: attributes_for(:reply, :for_comment, commenter: laura, commentable: @comment) }
          end.to change(Comment, :count).by(1)
        end

        it 'sends the reply as json response' do
          post "/v1/comments/#{@comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(:reply, :for_comment, commenter: laura, commentable: @comment) }

          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(%w[id commenter body created_at updated_at likes liked? like_id])
          expect(json_response['commenter']['username']).to eq(laura.username)
        end
      end

      context 'reply body is missing' do
        it 'sends an error response' do
          post "/v1/comments/#{@comment.id}/replies",
               headers: { "Authorization": "Bearer #{user_token}" },
               params: { reply: attributes_for(
                 :reply, :for_comment, commenter: laura, commentable: @comment, body: nil
               ) }

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
               comment: attributes_for(:reply, :for_comment, commenter: laura)
             }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'PUT and DELETE requests' do
    before do
      @comment = create(:comment, :for_post, commenter: dominic, commentable: @post)
      @reply = create(:reply, :for_comment, commenter: laura, commentable: @comment)
    end
    describe 'PUT /v1/comments/:id' do
      context 'Commenter updates his comment' do
        before { login_as(dominic) }

        context 'comment found' do
          context 'comment body present' do
            before do
              @updated_comment = 'Updated comment'

              put "/v1/comments/#{@comment.id}",
                  headers: { "Authorization": "Bearer #{user_token}" },
                  params: { comment: attributes_for(
                    :comment,
                    :for_post,
                    commenter: dominic, commentable: @post, body: @updated_comment
                  ) }
            end

            it 'updates the comment in the database' do
              @comment.reload
              expect(@comment.body).to eq(@updated_comment)
            end

            it 'sends the updated comment as response' do
              json_response = JSON.parse(response.body)
              expect(response).to have_http_status(:accepted)
              expect(json_response['id']).to eq(@comment.id)
              expect(json_response['commenter']['username']).to eq(dominic.username)
            end
          end

          context 'comment body missing' do
            it 'sends an error response' do
              put "/v1/comments/#{@comment.id}",
                  headers: { "Authorization": "Bearer #{user_token}" },
                  params: {
                    comment: attributes_for(:comment, :for_post, commentable: @post, commenter: dominic, body: nil)
                  }

              json_response = JSON.parse(response.body)

              expect(response).to have_http_status(:unprocessable_entity)

              expect(json_response['errors']['body']).to include("can't be blank")
            end
          end
        end

        context 'comment not found' do
          it 'sends a cannot found error response' do
            put '/v1/comments/someLostCommentId',
                headers: { "Authorization": "Bearer #{user_token}" },
                params: { comment: attributes_for(:comment, :for_post, commentable: @post, commenter: dominic) }

            json_response = JSON.parse(response.body)

            expect(response).to have_http_status(404)
            expect(json_response['message']).to match('Cannot find comment')
          end
        end
      end

      context 'Replier updates her reply' do
        before { login_as(laura) }

        context 'reply found' do
          context 'reply body present' do
            before do
              @updated_reply = 'Updated reply'
              put "/v1/comments/#{@reply.id}",
                  headers: { "Authorization": "Bearer #{user_token}" },
                  params: { comment: attributes_for(
                    :reply,
                    :for_comment,
                    commenter: laura, commentable: @comment, body: @updated_reply
                  ) }
            end

            it 'updates the reply on the database' do
              @reply.reload
              expect(@reply.body).to eq(@updated_reply)
            end

            it 'sends the updated reply as response' do
              json_response = JSON.parse(response.body)
              expect(response).to have_http_status(:accepted)
              expect(json_response['id']).to eq(@reply.id)
              expect(json_response['commenter']['username']).to eq(laura.username)
            end
          end

          context 'reply body missing' do
            it 'sends an error response' do
              put "/v1/comments/#{@reply.id}",
                  headers: { "Authorization": "Bearer #{user_token}" },
                  params: { comment: attributes_for(
                    :comment, :for_post, commentable: @comment, commenter: laura, body: nil
                  ) }

              json_response = JSON.parse(response.body)

              expect(response).to have_http_status(:unprocessable_entity)

              expect(json_response['errors']['body']).to include("can't be blank")
            end
          end
        end

        context 'comment not found' do
          it 'sends a cannot found error response' do
            put '/v1/comments/someLostCommentId',
                headers: { "Authorization": "Bearer #{user_token}" },
                params: { comment: attributes_for(:reply, :for_comment, commentable: @comment, commenter: laura) }

            json_response = JSON.parse(response.body)

            expect(response).to have_http_status(404)
            expect(json_response['message']).to match('Cannot find comment')
          end
        end
      end
    end

    describe 'DELETE /v1/comments/:id' do
      context 'deleting a post comment' do
        before do
          login_as(dominic)
        end

        context 'comment found' do
          it 'removes comment and reply from database' do
            expect do
              delete "/v1/comments/#{@comment.id}",
                     headers: { "Authorization": "Bearer #{user_token}" }
            end.to change(Comment, :count).by(-2)
          end

          it 'sends a success response' do
            delete "/v1/comments/#{@comment.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }

            json_response = JSON.parse(response.body)
            expect(json_response['message']).to match('Comment deleted')
          end
        end

        context 'comment not found' do
          it 'responds with an error json' do
            delete '/v1/comments/someLostCommentId',
                   headers: { "Authorization": "Bearer #{user_token}" }

            expect(response).to have_http_status(404)
            expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
          end
        end
      end

      context 'deleting a comment reply' do
        before do
          login_as(laura)
        end

        context 'comment found' do
          it 'removes reply from database' do
            expect do
              delete "/v1/comments/#{@reply.id}",
                     headers: { "Authorization": "Bearer #{user_token}" }
            end.to change(Comment, :count).by(-1)
          end

          it 'sends a success response' do
            delete "/v1/comments/#{@reply.id}",
                   headers: { "Authorization": "Bearer #{user_token}" }

            json_response = JSON.parse(response.body)
            expect(json_response['message']).to match('Comment deleted')
          end
        end

        context 'reply not found' do
          it 'responds with an error json' do
            delete '/v1/comments/someLostCommentId',
                   headers: { "Authorization": "Bearer #{user_token}" }

            expect(response).to have_http_status(404)
            expect(JSON.parse(response.body)['message']).to match('Cannot find comment')
          end
        end
      end
    end
  end
end
