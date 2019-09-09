# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostPolicy, type: :policy do
  let(:james) { create(:male_user, username: 'james') }
  let(:mario) { create(:male_user, username: 'mario') }
  let(:post) { create(:post, author: james, postable: mario) }

  describe 'policy for a post update' do
    subject { PostPolicy.new(james, post) }

    context 'updating the post on the right user timeline' do
      it do
        post.postable_param = mario
        is_expected.to permit_action(:update)
      end
    end

    context 'updating post on the wrong user timeline' do
      it do
        post.postable_param = james
        is_expected.to_not permit_action(:update)
      end
    end
  end
end
