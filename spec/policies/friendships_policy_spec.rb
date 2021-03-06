# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipPolicy, type: :policy do
  let(:kurt) { create(:user, :male, first_name: 'Kurt') }
  let(:mary) { create(:user, :male, first_name: 'Mary') }
  let(:friendship) { create(:friendship, active_friend: kurt, passive_friend: mary) }

  context 'policy for actions for a friend request receiver' do
    subject { FriendshipPolicy.new(mary, friendship) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'policy for actions for a friend request sender' do
    subject { FriendshipPolicy.new(kurt, friendship) }
    it { is_expected.to permit_action(:destroy) }
  end
end
