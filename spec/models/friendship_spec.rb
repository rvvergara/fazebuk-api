# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:ryto) { create(:male_user, username: 'ryto') }
  let(:james) { create(:male_user, username: 'james') }

  before do
    @friendship = create(:friendship, active_friend: ryto, passive_friend: james)
  end

  describe 'validations' do
    context 'james creates a duplicate friendship with ryto' do
      it 'is invalid' do
        duplicate_friendship = build(:friendship, active_friend: james, passive_friend: ryto)

        duplicate_friendship.valid?

        expect(duplicate_friendship.errors['combined_ids']).to include('has already been taken')
      end
    end

    context 'james sends himself a friend request' do
      it 'is invalid' do
        self_friendship = build(:friendship, active_friend: james, passive_friend: james)

        self_friendship.valid?

        expect(self_friendship.errors['active_friend']).to include('You cannot send yourself a friend request')
      end
    end
  end

  describe '#confirm' do
    it 'confirms the friendship between james and ryto' do
      @friendship.confirm
      expect(@friendship.confirmed).to eq(true)
    end
  end
end
