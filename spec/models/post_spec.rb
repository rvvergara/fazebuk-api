# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validation' do
    let(:charlie) { create(:male_user, username: 'charlie') }
    let(:kyle) { create(:male_user, username: 'kyle') }
    let(:post) { build(:post, author: charlie, postable: kyle) }

    context 'content present in post' do
      it 'is valid' do
        expect(post).to be_valid
      end
    end

    context 'post has no content' do
      it 'is contains an error saying content cannot be blank' do
        post.content = nil
        post.valid?
        expect(post.errors['content']).to be_include("can't be blank")
      end
    end
  end
end
