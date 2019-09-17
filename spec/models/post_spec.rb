# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:charlie) { create(:user, :male, first_name: 'Charlie') }
  let(:kyle) { create(:user, :male, first_name: 'Kyle') }
  let(:post) { build(:post, author: charlie, postable: kyle) }
  let!(:like) { create(:like, :for_post, likeable: post, liker: kyle) }
  let!(:pic1) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end
  let!(:pic2) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'blue-red-lake.jpg'), 'image/jpg')
  end

  after :all do
    remove_uploaded_files
  end

  describe 'validation' do
    context 'adding_or_purging_pic is false' do
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

    context 'adding_or_purging_pic is true' do
      it 'is valid' do
        post.adding_or_purging_pic = true
        post.content = nil
        expect(post).to be_valid
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
    it {
      should have_many(:pics_attachments)
    }
    context 'deleting a post with pics' do
      it 'also deletes associated pics' do
        post.pics = [pic1, pic2]
        post.save
        expect do
          post.destroy
        end
          .to change(ActiveStorage::Attachment, :count)
          .from(2).to(0)
      end
    end
  end
end
