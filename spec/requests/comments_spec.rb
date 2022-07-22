# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:bart) { create(:user, :male, first_name: 'Bart') }
  let(:lisa) { create(:user, :female, first_name: 'Lisa') }
  let!(:post_to_lisa) { create(:post, author: bart, postable: lisa) }
  let!(:comment) { create(:comment, :for_post, commenter: lisa, commentable: post_to_lisa) }
  let!(:reply) { create(:reply, :for_comment, commenter: bart, commentable: comment) }
  let!(:reply_with_pic) { create(:reply, :for_comment, :with_pic, commenter: bart, commentable: comment) }
  let!(:updated_body) { 'Updated body' }
  let(:pic) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end

  after :all do
    remove_uploaded_files
  end

  describe 'unauthenticated user requests' do
    it {
      post post_comments_route(post_to_lisa.id)

      expect(response).to have_http_status(:unauthorized)
    }

    it {
      post comment_replies_route(comment.id)

      expect(response).to have_http_status(:unauthorized)
    }

    it {
      put comment_route(comment.id)

      expect(response).to have_http_status(:unauthorized)
    }

    it {
      put comment_route(reply.id)

      expect(response).to have_http_status(:unauthorized)
    }

    it {
      delete comment_route(comment.id)

      expect(response).to have_http_status(:unauthorized)
    }

    it {
      delete comment_route(reply.id)

      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'POST /v1/posts/:post_id/comments' do
    let!(:login) { login_as(lisa) }

    context 'post exists' do
      context 'valid params' do
        subject do
          post post_comments_route(post_to_lisa.id),
               headers: authorization_header,
               params: valid_comment_attributes(:comment)
        end

        it 'saves to the database' do
          expect { subject }.to change(Comment, :count).by(1)
        end

        it 'sends created comment as response' do
          subject
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(comment_response_keys(post_to_lisa.comments.last))
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

      context 'with comment pic' do
        context 'with body' do
          subject do
            post post_comments_route(post_to_lisa.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:comment, pic: pic)
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'adds comment to db' do
            expect { subject }
              .to change(Comment, :count).by(1)
          end

          it 'sends new comment data as response' do
            subject
            expect(response).to have_http_status(:created)
            expect(json_response.keys).to match(comment_response_keys(Comment.last))
            expect(json_response['pic']['id']).to eq(Comment.last.pic.id)
          end
        end

        context 'without body' do
          subject do
            post post_comments_route(post_to_lisa.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:comment, pic: pic, body: nil)
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'adds comment to the db' do
            expect { subject }
              .to change(Comment, :count).by(1)
          end

          it 'sends new comment data as response' do
            subject
            expect(response).to have_http_status(:created)
            expect(json_response.keys).to match(comment_response_keys(post_to_lisa.comments.last))
            expect(json_response['pic']['id']).to eq(Comment.last.pic.id)
          end
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        post post_comments_route('nonExistentPostId'),
             headers: authorization_header,
             params: { comment: attributes_for(:comment, :for_post) }

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/comments/:comment_id/replies' do
    let!(:login) { login_as(bart) }

    context 'comment exists' do
      context 'valid params' do
        subject do
          post comment_replies_route(comment.id),
               headers: authorization_header,
               params: valid_comment_attributes(:reply)
        end

        it 'saves to the database' do
          expect { subject }.to change(Comment, :count).by(1)
        end

        it 'sends created reply as response' do
          subject
          expect(response).to have_http_status(:created)
          expect(json_response.keys).to match(comment_reply_response_keys(comment.replies.last))
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

      context 'with reply pic' do
        context 'with body' do
          subject do
            post comment_replies_route(comment.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:reply, pic: pic)
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'adds reply to the db' do
            expect { subject }
              .to change(Comment, :count).by(1)
          end

          it 'sends the new reply data as response' do
            subject
            expect(response).to have_http_status(:created)
            expect(json_response.keys).to match(comment_reply_response_keys(comment.replies.last))
            expect(json_response['pic']['id']).to eq(comment.replies.last.pic.id)
          end
        end

        context 'without body' do
          subject do
            post comment_replies_route(comment.id),
                 headers: authorization_header,
                 params: valid_comment_attributes(:reply, pic: pic, body: nil)
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'adds reply to the db' do
            expect { subject }
              .to change(Comment, :count).by(1)
          end

          it 'sends the new reply data as response' do
            subject
            expect(response).to have_http_status(:created)
            expect(json_response.keys).to match(comment_reply_response_keys(comment.replies.last))
            expect(json_response['pic']['id']).to eq(comment.replies.last.pic.id)
          end
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        post comment_replies_route('nonExistentCommentId'),
             headers: authorization_header,
             params: valid_comment_attributes(:reply)

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'PUT /v1/comments/:id' do
    let!(:login) { login_as(bart) }

    context 'comment exists' do
      context 'valid params' do
        subject! do
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
          expect(reply.body).not_to eq(updated_body)
        end

        it 'sends an error response' do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']['body']).to include("can't be blank")
        end
      end

      context 'adding pic to existing comment' do
        context 'with body in update' do
          subject do
            put comment_route(reply.id),
                headers: authorization_header,
                params: valid_comment_attributes('comment', body: updated_body, pic: pic)

            reply.reload
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'adds pic to the comment w/ updated comment' do
            subject
            expect(reply.pic.filename).to eq(pic.original_filename)
            expect(reply.body).to eq(updated_body)
          end

          it 'sends the updated reply data as response' do
            subject
            expect(response).to have_http_status(:accepted)
            expect(json_response.keys).to match(comment_reply_response_keys(reply))
            expect(json_response['pic']['id']).to eq(reply.pic.id)
          end
        end

        context 'without body in update' do
          subject do
            put comment_route(reply.id),
                headers: authorization_header,
                params: valid_comment_attributes('comment', body: nil, pic: pic)

            reply.reload
          end

          it 'adds attachment to the db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(1)
          end

          it 'updates the reply' do
            subject
            expect(reply.pic.filename).to eq(pic.original_filename)
            expect(reply.body).to eq('')
          end
        end
      end

      context 'removing pic from an existing comment' do
        context 'with body in update' do
          subject do
            put comment_route(reply_with_pic.id),
                headers: authorization_header,
                params: valid_comment_attributes('comment', body: updated_body, purge_pic: '1')

            reply_with_pic.reload
          end

          it 'removes attachment from db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(-1)
          end

          it 'removes pic from the comment' do
            subject
            expect(reply_with_pic.pic.attached?).to be(false)
          end

          it 'sends the updated comment as response' do
            subject
            expect(response).to have_http_status(:accepted)
            expect(json_response.keys).to match(comment_reply_response_keys(reply_with_pic))
          end
        end

        context 'without body in update' do
          subject do
            put comment_route(reply_with_pic.id),
                headers: authorization_header,
                params: valid_comment_attributes('comment', body: nil, purge_pic: '1')

            reply_with_pic.reload
          end

          it 'removes attachment from db' do
            expect { subject }
              .to change(ActiveStorage::Attachment, :count).by(-1)
          end

          it 'removes pic from comment' do
            subject
            expect(reply_with_pic.pic.attached?).to be(false)
          end

          it 'sends an error message' do
            subject
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']['body']).to include("can't be blank")
          end
        end
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        put comment_route('nonExistentCommentId'),
            headers: authorization_header,
            params: valid_comment_attributes(:reply)

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end

  describe 'DELETE /v1/comments/:id' do
    let!(:login) { login_as(lisa) }

    context 'comment exists' do
      subject do
        delete comment_route(comment.id),
               headers: authorization_header
      end

      it 'removes comment (and replies) from db' do
        expect { subject }.to change(Comment, :count).by(-3)
      end

      it 'sends a success response' do
        subject
        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Comment deleted')
      end
    end

    context 'comment does not exist' do
      it 'sends an error response' do
        delete comment_route('nonExistentCommentId'),
               headers: authorization_header

        expect(response).to have_http_status(:not_found)
        expect(json_response['message']).to match('Cannot find comment')
      end
    end
  end
end
