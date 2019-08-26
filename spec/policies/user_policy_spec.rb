# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:jane) { create(:user, username: 'jane') }
  let(:miri) { create(:user, username: 'miri') }

  context 'jane managing her own account' do
    subject { UserPolicy.new(jane, jane) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "jane tampering with miri's account" do
    subject { UserPolicy.new(jane, miri) }
    it { is_expected.to_not permit_action(:update) }
    it { is_expected.to_not permit_action(:destroy) }
  end
end
