# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:ryto) { create(:user, :male, first_name: 'Ryto') }
  let(:james) { create(:user, :male, first_name: 'James') }
  let!(:valid_request) { create(:request, active_friend: ryto, passive_friend: james) }
  let(:invalid_request) { build(:request, active_friend: james, passive_friend: ryto) }
  let(:request_to_self) { build(:request, active_friend: james, passive_friend: james) }

  describe 'validations' do
    context 'friend request to a friend' do
      it 'is invalid' do
        invalid_request.valid?

        expect(invalid_request.errors['combined_ids']).to include('has already been taken')
      end
    end

    context 'friend request to self' do
      it 'is invalid' do
        request_to_self.valid?

        expect(request_to_self.errors['active_friend']).to include('You cannot send yourself a friend request')
      end
    end
  end

  describe '#confirm' do
    it 'confirms the friendship between james and ryto' do
      valid_request.confirm
      expect(valid_request.confirmed).to eq(true)
    end
  end
end
