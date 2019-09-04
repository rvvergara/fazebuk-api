# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users::Friends', type: :request do
  let(:harry) { create(:user, username: 'harry') }
  let(:hermione) { create(:user, username: 'hermione') }
  let(:goku) { create(:user, username: 'goku') }

  describe 'GET /v1/users/:user_username/friends' do
    before do
      [harry, hermione].each do |friend|
        create(:friendship, active_friend: goku, passive_friend: friend, confirmed: true)
      end
    end
    context 'harry visits his mutual friends with hermione page' do
      it 'returns an array w/ goku in it' do
        login_as(harry)
        get "/v1/users/#{harry.username}/mutual_friends",
            headers: { "Authorization": "Bearer #{user_token}" }

        expect(JSON.parse(response.body).size).to be(2)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
