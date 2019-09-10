# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:marge) { create(:female_user, username: 'marge') }
  let(:rolo) { create(:male_user, username: 'rolo') }
  let(:post) { create(:post, author: marge, postable: rolo) }
  let(:comment) { build(:post_comment, commenter: rolo, commentable: post) }

  describe 'validations' do
    context 'body present' do
      it 'is valid' do
        expect(comment).to be_valid
      end
    end

    context 'body missing' do
      it 'is invalid' do
        comment.body = nil
        comment.valid?
        expect(comment.errors['body']).to include("can't be blank")
      end
    end
  end

  describe 'inherited #like_id' do
    before { comment.save }

    context 'user has liked the comment' do
      it 'returns like id' do
        like = create(:like, :for_post_comment, likeable: comment, liker: marge)
        expect(comment.like_id(marge)).to eq(like.id)
      end
    end

    context 'user has not liked the comment' do
      it 'returns nil' do
        expect(comment.like_id(marge)).to eq(nil)
      end
    end
  end

  describe 'associations' do
    it {
      should belong_to(:commenter)
        .class_name('User')
    }
    it { should belong_to(:commentable) }
    it {
      should have_many(:replies)
        .with_foreign_key(:commentable_id)
        .class_name('Comment')
        .dependent(:destroy)
    }
    it {
      should have_many(:likes)
        .with_foreign_key(:likeable_id)
        .dependent(:destroy)
    }
  end
end
