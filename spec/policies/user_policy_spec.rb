# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:jane) { create(:user, :male, first_name: 'Jane') }
  let(:miri) { create(:user, :male, first_name: 'Miri') }

  context 'when policy for a user managing their own account' do
    subject { described_class.new(jane, jane) }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "policy for a user tampering another's account" do
    subject { described_class.new(jane, miri) }

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end
end
