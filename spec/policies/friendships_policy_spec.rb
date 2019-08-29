# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipPolicy, type: :policy do
  let(:kurt) { create(:user, username: 'kurt') }
  let(:mary) { create(:user, username: 'mary') }
  let(:friendship) { create(:friendship, active_friend: kurt, passive_friend: mary) }

  context 'mary can either confirm or reject the request' do
    subject { FriendshipPolicy.new(mary, friendship) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'kurt can cancel the request' do
    subject { FriendshipPolicy.new(kurt, friendship) }
    it { is_expected.to permit_action(:destroy) }
  end
end
