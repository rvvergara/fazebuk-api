# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe '#create' do
    let(:john) { create(:user, :male, first_name: 'John') }

    context 'correct credentials' do
      subject! do
        post '/v1/sessions', params: {
          email: john.email,
          password: 'password'
        }
      end

      it 'has a response of ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders a json with complete data' do
        expect(json_response['username']).to eq(john.username)
        expect(json_response['token']).not_to be('')
      end
    end
  end
end
