# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    let(:marge) { create(:female_user) }
    let(:rolo) { create(:male_user) }
    let(:post) { create(:post, author: marge, postable: rolo) }
    let(:comment) { build(:post_comment, commenter: rolo, commentable: post) }

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
  end
end
