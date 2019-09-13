# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:mark) { create(:user, :male, first_name: 'Mark') }
  let(:luke) { create(:user, :male, first_name: 'Luke') }
  let(:post) { create(:post, author: mark, postable: luke) }
  let(:comment) { create(:comment, :for_post, commenter: luke, commentable: post) }
  let!(:like) { create(:like, :for_post, likeable: post, liker: luke) }

  describe 'validation' do
    context 'duplicate like' do
      it 'is invalid' do
        duplicate = build(:like, :for_post, liker: luke, likeable: post)
        duplicate.valid?
        expect(duplicate.errors['liker']).to include('cannot like the post twice')
      end

      context 'unique like' do
        it 'is valid' do
          comment_like = build(:like, :for_comment, liker: mark, likeable: comment)
          expect(comment_like).to be_valid
        end
      end
    end
  end
end
