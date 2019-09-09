# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:mark) { create(:male_user, username: 'mark') }
  let(:luke) { create(:male_user, username: 'luke') }
  let(:post) { create(:post, author: mark, postable: luke) }
  let(:comment) { create(:post_comment, commenter: luke, commentable: post) }
  let!(:like) { create(:like, :for_post, likeable: post, liker: luke) }

  describe 'validation' do
    context 'duplicate like' do
      it 'is invalid' do
        duplicate = build(:like, :for_post, liker: luke, likeable: post)
        duplicate.valid?
        expect(duplicate.errors['liker']).to include('cannot like the Post twice')
      end

      context 'unique like' do
        it 'is valid' do
          comment_like = build(:like, :for_post_comment, liker: mark, likeable: comment)
          expect(comment_like).to be_valid
        end
      end
    end
  end
end
