# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Friends', type: :request do
  let(:harry) { create(:male_user, username: 'harry') }
  let(:hermione) { create(:female_user, username: 'hermione') }
  let(:goku) { create(:male_user, username: 'goku') }

  describe 'GET /v1/users/:user_username/friends' do
    before do
      [harry, hermione].each do |friend|
        create(:friendship, active_friend: goku, passive_friend: friend, confirmed: true)
      end
    end
    context 'goku logs on to check his friends' do
      it 'gives him an array of json data of his friends' do
        login_as(goku)
        get "/v1/users/#{goku.username}/friends",
            headers: { "Authorization": "Bearer #{user_token}" }
        json_response = JSON.parse(response.body)
        expect(json_response['friends'].size).to be(2)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
