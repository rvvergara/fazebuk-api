# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe '#show' do
    let(:alfred) { create(:user, username: 'alfred') }

    it 'returns a good response' do
      get "/v1/users/#{alfred.username}"
      expect(response).to have_http_status(:ok)
    end
  end
end
