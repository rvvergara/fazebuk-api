# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:charlie) { create(:user, :male, first_name: 'Charlie') }
  let(:kyle) { create(:user, :male, first_name: 'Kyle') }
  let(:post) { build(:post, author: charlie, postable: kyle) }
  let!(:like) { create(:like, :for_post, likeable: post, liker: kyle) }

  describe 'validation' do
    context 'content present in post' do
      it 'is valid' do
        expect(post).to be_valid
      end
    end

    context 'post has no content' do
      it 'is invalid and has errors' do
        post.content = nil
        post.valid?
        expect(post.errors['content']).to be_include("can't be blank")
      end
    end
  end

  describe 'inherited #like_id' do
    let!(:save) { post.save }

    context 'user has liked the post' do
      it 'returns like id' do
        expect(post.like_id(kyle)).to eq(like.id)
      end
    end
    context 'user has not liked the post' do
      it 'returns nil' do
        expect(post.like_id(charlie)).to be(nil)
      end
    end
  end

  describe 'associations' do
    it {
      should belong_to(:postable)
        .class_name('User')
    }
    it {
      should belong_to(:author)
        .class_name('User')
    }
    it {
      should have_many(:comments)
        .with_foreign_key(:commentable_id)
        .dependent(:destroy)
    }
    it {
      should have_many(:likes)
        .with_foreign_key(:likeable_id)
        .dependent(:destroy)
    }
  end
end
