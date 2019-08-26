# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe '#create' do
    let(:john) { create(:user, username: 'john', email: 'john@gmail.com') }
    context 'correct credentials' do
      before do
        post '/v1/sessions', params: {
          email_or_username: john.username,
          password: 'password'
        }
      end
      it 'has a response of ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders a json with complete data' do
        json_response = JSON.parse(response.body)['user']
        expect(json_response['data']['username']).to eq(john.username)
        expect(json_response['token']).to_not be('')
      end
    end
  end
end
