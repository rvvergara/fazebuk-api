# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:marge) { create(:user, :female, first_name: 'Marge') }
  let(:rolo) { create(:user, :male, first_name: 'Rolo') }
  let(:post) { create(:post, author: marge, postable: rolo) }
  let(:comment) { build(:comment, :for_post, commenter: rolo, commentable: post) }
  let(:pic) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end

  after :all do
    remove_uploaded_files
  end

  describe 'validations' do
    context 'body present' do
      it 'is valid' do
        expect(comment).to be_valid
      end
    end

    context 'body missing' do
      context 'pic also missing' do
        it 'is invalid' do
          comment.body = nil
          comment.valid?
          expect(comment.errors['body']).to include("can't be blank")
        end
      end
      context 'pic is present' do
        it 'is valid' do
          comment.body = nil
          comment.pic = pic
          comment.adding_or_purging_pic = true
          expect(comment).to be_valid
        end
      end
    end
  end

  describe 'inherited #like_id' do
    let!(:save) { comment.save }

    context 'user has liked the comment' do
      it 'returns like id' do
        like = create(:like, :for_comment, likeable: comment, liker: marge)
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
    context 'attached pic' do
      it {
        should have_one(:pic_attachment)
      }

      context 'deleting a comment' do
        it 'deletes the associated pic' do
          comment.pic = pic
          comment.save
          expect do
            comment.destroy
          end
            .to change(ActiveStorage::Attachment, :count)
            .from(1).to(0)
        end
      end
    end
  end
end
