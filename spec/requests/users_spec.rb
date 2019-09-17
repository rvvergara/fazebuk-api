# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:alfred) { create(:user, :male, first_name: 'Alfred') }
  let(:conrad) { create(:user, :male, first_name: 'Conrad') }
  let!(:friendship) { create(:friendship, :confirmed, active_friend: alfred, passive_friend: conrad) }
  let(:profile_pic1) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'kayi.jpg'), 'image/jpg')
  end

  let(:profile_pic2) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'male.jpg'), 'image/jpg')
  end

  let(:cover_pic1) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'blue-red-lake.jpg'), 'image/jpg')
  end

  let(:cover_pic2) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end

  let!(:login) { login_as(alfred) }

  after :all do
    remove_uploaded_files
  end

  describe 'unauthenticated user requests' do
    it {
      get user_route(alfred.username)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      put user_route(alfred.username)
      expect(response).to have_http_status(:unauthorized)
    }
    it {
      delete user_route(alfred.username)
      expect(response).to have_http_status(:unauthorized)
    }
  end

  describe 'GET /v1/users/:username' do
    context 'user exists' do
      it 'sends the user data as response' do
        get user_route(conrad.username),
            headers: authorization_header

        expect(response).to have_http_status(:ok)
        expect(json_response.keys).to match(user_response_keys)
        expect(json_response['is_already_a_friend?']).to be(true)
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        get user_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end

  describe 'POST /v1/users' do
    context 'valid params' do
      it 'creates & authenticates user' do
        expect { create_user(valid_user_attributes) }
          .to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        expect(json_response['token']).to eq(user_token)
      end
    end

    context 'invalid params' do
      context 'missing first_name' do
        it 'does not create a user' do
          expect { create_user(invalid_user_attributes) }
            .to_not change(User, :count)

          expect(json_response['message']).to match('Cannot create user')
        end
      end

      context 'duplicate username' do
        it 'does not create user' do
          expect do
            create_user(valid_user_attributes.merge(username: conrad.username))
          end
            .to_not change(User, :count)

          expect(json_response['errors']['username']).to include('has already been taken')
        end
      end
    end
  end

  describe 'PUT /v1/users/:username' do
    let!(:login) { login_as(alfred) }

    context 'user exists' do
      context 'valid params' do
        before { update_user(alfred.username, first_name: 'King') }

        it 'changes user record' do
          alfred.reload
          expect(alfred.first_name).to eq('King')
        end

        it 'sends updated user data as response' do
          expect(response).to have_http_status(:accepted)
          expect(json_response.keys).to match(user_response_keys)
          expect(json_response['first_name']).to eq('King')
        end
      end

      context 'invalid params' do
        context 'missing first name' do
          before { update_user(alfred.username, invalid_user_attributes) }

          it 'does not update user record' do
            alfred.reload
            expect(alfred.first_name).to eq('Alfred')
          end

          it 'sends an error response' do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response['errors']['first_name']).to include("can't be blank")
          end
        end

        context 'duplicate username' do
          before { update_user(alfred.username, username: conrad.username) }

          it 'does not change user record' do
            alfred.reload

            expect(alfred.username).to eq('alfred')
          end
        end
      end

      context 'request for profile pic change' do
        context 'with new image upload' do
          subject do
            update_user(alfred.username, profile_images: [profile_pic1])
          end

          it 'uploads a new image' do
            expect { subject }.to change(ActiveStorage::Attachment, :count).from(0).to(1)
          end

          it "changes the user's profile_pic" do
            subject
            alfred.reload
            expect(alfred.profile_pic).to eq(
              rails_blob_path(alfred.profile_images.last)
            )
          end
        end

        context 'referring to url of a previously uploaded image' do
          subject! do
            update_user(alfred.username, profile_images: [profile_pic1])
            login_as(alfred)
            update_user(alfred.username, profile_images: [profile_pic2])
            login_as(alfred)
            update_user(alfred.username, profile_pic: rails_blob_path(
              alfred.ordered_profile_images.first, only_path: true
            ))
            alfred.reload
          end

          it 'changes profile pic of user' do
            pic_url = rails_blob_path(alfred.ordered_profile_images.first, only_path: true)
            expect(alfred.profile_pic).to eq(pic_url)
          end
        end
      end

      context 'request for cover pic change' do
        context 'with new image upload' do
          subject do
            update_user(alfred.username, cover_images: [cover_pic1])
          end

          it 'uploads image to db' do
            expect { subject }.to change(ActiveStorage::Attachment, :count).from(0).to(1)
          end

          it "changes the user's cover pic" do
            subject
            alfred.reload
            expect(alfred.cover_pic).to eq(
              rails_blob_path(alfred.cover_images.last, only_path: true)
            )
          end
        end

        context 'referring to url of a previously uploaded image' do
          subject! do
            update_user(alfred.username, cover_images: [cover_pic1])
            login_as(alfred)
            update_user(alfred.username, cover_images: [cover_pic2])
            login_as(alfred)
            update_user(alfred.username, cover_pic: rails_blob_path(
              alfred.ordered_cover_images.first, only_path: true
            ))
            alfred.reload
          end

          it 'changes cover pic for user' do
            pic_url = rails_blob_path(
              alfred.ordered_cover_images.first, only_path: true
            )
            expect(alfred.cover_pic).to eq(pic_url)
          end
        end
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        put user_route('nobody'),
            headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end

  describe 'DELETE /v1/users/:username' do
    context 'user exists' do
      subject do
        delete user_route(alfred.username),
               headers: authorization_header
      end

      it 'removes user record from the db' do
        expect { subject }.to change(User, :count).by(-1)
      end

      it 'sends a success response' do
        subject
        expect(response).to have_http_status(:accepted)
        expect(json_response['message']).to match('Account deleted')
      end
    end

    context 'user does not exist' do
      it 'sends an error response' do
        delete user_route('nobody'),
               headers: authorization_header

        expect(response).to have_http_status(404)
        expect(json_response['message']).to match('Cannot find user')
      end
    end
  end
end
