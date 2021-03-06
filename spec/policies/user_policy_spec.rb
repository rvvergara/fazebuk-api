# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:jane) { create(:user, :male, first_name: 'Jane') }
  let(:miri) { create(:user, :male, first_name: 'Miri') }

  context 'policy for a user managing their own account' do
    subject { UserPolicy.new(jane, jane) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "policy for a user tampering another's account" do
    subject { UserPolicy.new(jane, miri) }
    it { is_expected.to_not permit_action(:update) }
    it { is_expected.to_not permit_action(:destroy) }
  end
end
