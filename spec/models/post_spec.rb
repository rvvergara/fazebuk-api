# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:charlie) { create(:user, :male, first_name: 'Charlie') }
  let(:kyle) { create(:user, :male, first_name: 'Kyle') }
  let(:post) { build(:post, author: charlie, postable: kyle) }
  let!(:like) { create(:like, :for_post, likeable: post, liker: kyle) }
  let(:pic1) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'icy-lake.jpg'), 'image/jpg')
  end
  let(:pic2) do
    fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'blue-red-lake.jpg'), 'image/jpg')
  end

  after :all do
    remove_uploaded_files
  end

  describe 'validation' do
    context 'when adding_or_purging_pic is false' do
      context 'when content present in post' do
        it 'is valid' do
          expect(post).to be_valid
        end
      end

      context 'when post has no content' do
        it 'is invalid and has errors' do
          post.content = nil
          post.valid?
          expect(post.errors['content']).to be_include("can't be blank")
        end
      end
    end

    context 'when adding_or_purging_pic is true' do
      it 'is valid' do
        post.adding_or_purging_pic = true
        post.content = nil
        expect(post).to be_valid
      end
    end
  end

  describe 'inherited #like_id' do
    let!(:save) { post.save }

    context 'when user has liked the post' do
      it 'returns like id' do
        expect(post.like_id(kyle)).to eq(like.id)
      end
    end

    context 'when user has not liked the post' do
      it 'returns nil' do
        expect(post.like_id(charlie)).to be_nil
      end
    end
  end

  describe '#modified_update' do
    context 'when adding a pic to a saved post' do
      before do
        pics = [pic1]
        post.save
        post.modified_update(pics: pics)
      end

      it 'updates the post w/ the new pic' do
        expect(post.pics.count).to be(1)
        expect(post.pics.first.filename).to eq(pic1.original_filename)
      end
    end

    context 'when deleting a pic from a saved post' do
      before do
        post.pics = [pic1, pic2]
        post.save
        purge_id = post.pics.first.id
        post.modified_update(purge_pic: purge_id)
      end

      it 'removes the pic from the updated post' do
        expect(post.pics.count).to be(1)
      end

      context 'when post w/ all pics removed' do
        it 'is invalid w/o content' do
          post.content = nil
          post.modified_update(purge_pic: post.pics.first.id)

          expect(post.errors['content']).to be_include("can't be blank")
        end
      end
    end
  end

  describe 'associations' do
    it {
      expect(subject).to belong_to(:postable)
        .class_name('User')
    }

    it {
      expect(subject).to belong_to(:author)
        .class_name('User')
    }

    it {
      expect(subject).to have_many(:comments)
        .with_foreign_key(:commentable_id)
        .dependent(:destroy)
    }

    it {
      expect(subject).to have_many(:likes)
        .with_foreign_key(:likeable_id)
        .dependent(:destroy)
    }

    it {
      expect(subject).to have_many(:pics_attachments)
    }

    context 'when deleting a post with pics' do
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
