# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::TimelinePosts', type: :request do
  describe '/v1/users/:user_username/timeline_posts' do
    let(:richie) { create(:user, username: 'richie') }
    let(:abel) { create(:user, username: 'abel') }
    before do
      create(:friendship, active_friend: richie, passive_friend: abel)
      @post1 = create(:post, author: richie, postable: abel, content: Faker::Lorem.paragraph(sentence_count: 3))
      @post2 = create(:post, author: abel, postable: richie, content: Faker::Lorem.paragraph(sentence_count: 3))
      login_as(richie)
    end

    context 'user exists' do
      it 'responds with the collection of posts' do
        get "/v1/users/#{abel.username}/timeline_posts",
            headers: { "Authorization": "Bearer #{user_token}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['timeline_posts'].count).to be(2)
      end

      context 'user does not exist' do
        it 'has User cannot be found response' do
          get '/v1/users/abuel/timeline_posts',
              headers: { "Authorization": "Bearer #{user_token}" }

          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)['message']).to include('Cannot find user')
        end
      end
    end
  end
end
