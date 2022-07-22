# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostPolicy, type: :policy do
  let(:james) { create(:user, :male, first_name: 'James') }
  let(:mario) { create(:user, :male, first_name: 'Mario') }
  let(:post) { create(:post, author: james, postable: mario) }

  describe 'policy for a post update' do
    subject { described_class.new(james, post) }

    context 'updating the post on the right user timeline' do
      it do
        post.postable_param = mario
        expect(subject).to permit_action(:update)
      end
    end

    context 'updating post on the wrong user timeline' do
      it do
        post.postable_param = james
        expect(subject).not_to permit_action(:update)
      end
    end
  end
end
