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
    context 'harry visits his mutual friends with hermione page' do
      it 'returns an array w/ goku in it' do
        login_as(harry)
        get "/v1/users/#{hermione.username}/mutual_friends",
            headers: { "Authorization": "Bearer #{user_token}" }

        json_response = JSON.parse(response.body)
        expect(json_response['mutual_friends'].size).to be(1)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
