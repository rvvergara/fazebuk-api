# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FriendshipPolicy, type: :policy do
  let(:ryan) { create(:user, username: 'rvvergara') }
  let(:anna) { create(:user, username: 'anna') }
  let(:friendship) { create(:friendship, active_friend: ryan, passive_friend: anna) }

  context "anna confirms ryan's request" do
    subject { FriendshipPolicy.new(anna, friendship) }
    it { is_expected.to permit_action(:update) }
  end
end
