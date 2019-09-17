# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:beng) { create(:user, :female, first_name: 'Beng') }
  let(:karen) { create(:user, :female, first_name: 'Karen') }
  let!(:post_to_karen) { create(:post, author: beng, postable: karen) }
  let!(:login) { login_as(beng) }
  let(:pic1) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end
  let!(:pic2) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'blue-red-lake.jpg'), 'image/jpg')
  end
  let(:post_with_pic) { create(:post, author: beng, postable: beng, pics: [pic1, pic2]) }

  after :all do
    remove_uploaded_files
  end

  describe 'requests by unauthenticated user' do
    it {
      get post_route(post_to_karen.id)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      post post_route,
           params: valid_post_attributes(karen)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put post_route(post_to_karen.id)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete post_route(post_to_karen.id)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/posts/:id' do
    context 'post exists' do
      subject! do
        get post_route(post_to_karen.id),
            headers: authorization_header
      end

      it 'sends a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'sends the json data of post' do
        expect(json_response.keys)
          .to match(post_response_keys)

        expect(json_response['posted_to']['username']).to eq(karen.username)
        expect(json_response['author']['username']).to eq(beng.username)
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        get post_route('nonExistentPostId'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'POST /v1/posts' do
    context 'complete and valid post params' do
      subject do
        post post_route,
             headers: authorization_header,
             params: valid_post_attributes(beng)
      end

      it 'adds post to the database' do
        expect { subject }.to change(Post, :count).by(1)
      end

      it 'responds w/ data of created post' do
        subject
        expect(response).to have_http_status(:created)
        expect(json_response.keys).to match(post_response_keys)
        expect(json_response['author']['username']).to eq(beng.username)
        expect(json_response['posted_to']['username']).to eq(beng.username)
      end
    end

    context 'incomplete or invalid post params' do
      it 'sends an error response' do
        post post_route,
             headers: authorization_header,
             params: invalid_post_attributes(karen)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['message']).to match('Cannot create post')
        expect(json_response['errors']['content']).to include("can't be blank")
      end
    end

    context 'post with pics' do
      subject do
        post post_route,
             headers: authorization_header,
             params: valid_post_attributes(beng, pics: [pic1])
      end

      it 'adds post to the database' do
        expect { subject }.to change(Post, :count).by(1)
      end

      it 'adds ActiveStorage record' do
        expect { subject }
          .to change(ActiveStorage::Attachment, :count)
          .from(0).to(1)
      end

      it 'sends the post data as response' do
        subject
        expect(response).to have_http_status(:created)
        expect(json_response.keys).to match(post_response_keys)
        expect(json_response['pics'].first['id']).to eq(beng.authored_posts.order_created.first.pics.first.id)
      end
    end
  end

  describe 'PUT /v1/posts/:id' do
    let(:updated_content) { 'Updated content' }

    context 'post exists' do
      context 'valid post params' do
        subject! do
          put post_route(post_to_karen.id),
              headers: authorization_header,
              params: valid_post_attributes(karen, content: updated_content)

          post_to_karen.reload
        end

        it 'updates the post on the db' do
          expect(post_to_karen.content).to eq(updated_content)
        end

        it 'sends the updated post as response' do
          expect(response).to have_http_status(:accepted)

          expect(json_response['content']).to match(updated_content)
        end
      end

      context 'invalid post params' do
        subject! do
          put post_route(post_to_karen.id),
              headers: authorization_header,
              params: invalid_post_attributes(karen)

          post_to_karen.reload
        end

        it 'does not change post in the db' do
          expect(post_to_karen.content).to_not eq('')
        end

        it 'sends error response' do
          expect(json_response['errors']['content']).to include("can't be blank")
        end
      end

      context 'adding pics to post' do
        subject do
          put post_route(post_to_karen.id),
              headers: authorization_header,
              params: valid_post_attributes(karen, pics: [pic1])
        end

        it 'adds ActiveStorage::Attachment record' do
          expect { subject }
            .to change(ActiveStorage::Attachment, :count)
            .by(1)
        end

        it 'adds picture to the post' do
          subject
          post_to_karen.reload
          expect(post_to_karen.pics.first.filename).to eq(pic1.original_filename)
        end

        it 'sends updated post data' do
          subject
          expect(response).to have_http_status(:accepted)
          expect(json_response['pics'].first['id']).to eq(post_to_karen.pics.first.id)
        end
      end

      context 'deleting pic from post' do
        subject! do
          put post_route(post_with_pic.id),
              headers: authorization_header,
              params: valid_post_attributes(beng, purge_pic: post_with_pic.pics.first.id)

          post_with_pic.reload
        end

        it 'removes pic from post' do
          expect(post_with_pic.pics.count).to be(1)
        end

        it 'sends updated post data as response' do
          expect(response).to have_http_status(:accepted)
          expect(json_response['pics'].first['id']).to eq(post_with_pic.pics.first.id)
        end
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        put post_route('nonExistentPostId'),
            headers: authorization_header,
            params: valid_post_attributes(beng)

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end

  describe 'DELETE /v1/posts/:id' do
    context 'post exists' do
      subject do
        delete post_route(post_to_karen.id),
               headers: authorization_header
      end

      it 'removes post from db' do
        expect { subject }.to change(Post, :count).by(-1)
      end

      it 'sends a success response' do
        subject
        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Post deleted')
      end
    end

    context 'post does not exist' do
      it 'sends an error response' do
        delete post_route('nonExistentPostId'),
               headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find post')
      end
    end
  end
end
