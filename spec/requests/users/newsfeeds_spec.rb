# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Newsfeeds', type: :request do
  describe '/v1/newsfeed_posts' do
    let(:lydia) { create(:female_user, username: 'lydia') }
    let(:emily) { create(:female_user, username: 'emily') }
    let(:ariel) { create(:male_user, username: 'ariel') }
    before do
      create(:friendship, active_friend: ariel, passive_friend: lydia, confirmed: true)
      create(:friendship, active_friend: lydia, passive_friend: emily, confirmed: true)
      create(:friendship, active_friend: emily, passive_friend: ariel, confirmed: true)
      @post1 = create(:post, author: ariel, postable: lydia, content: Faker::Lorem.paragraph(sentence_count: 3))
      @post2 = create(:post, author: lydia, postable: emily, content: Faker::Lorem.paragraph(sentence_count: 3))
      @post2 = create(:post, author: emily, postable: ariel, content: Faker::Lorem.paragraph(sentence_count: 3))
      login_as(ariel)
    end

    context 'page params within max_pages' do
      it 'responds with newsfeed posts the of page' do
        get '/v1/newsfeed_posts?page=1',
            headers: { "Authorization": "Bearer #{user_token}" }
        json_response = JSON.parse(response.body)
        expect(json_response['newsfeed_posts'].count).to be(3)
      end
    end

    context 'page params exceed max_pages' do
      it 'responds with a message no more posts to show' do
        get '/v1/newsfeed_posts?page=3',
            headers: { "Authorization": "Bearer #{user_token}" }
        expect(JSON.parse(response.body)['message']).to match('No more newsfeed posts to show')
      end
    end
  end
end
