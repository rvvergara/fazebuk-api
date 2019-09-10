# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:mike) { build(:user, :male, first_name: 'Mike') }
    context 'complete basic info' do
      it 'is valid' do
        expect(mike).to be_valid
      end
    end

    context 'first_name absent' do
      it 'is invalid' do
        mike.first_name = nil
        expect(mike).to_not be_valid
      end
    end
  end

  describe 'friendship methods' do
    let(:ryto) { create(:user, :male, first_name: 'Ryto') }
    let(:mike) { create(:user, :male, first_name: 'Mike') }
    let(:anna) { create(:user, :female, first_name: 'Anna') }
    let(:george) { create(:user, :male,first_name: 'George') }
    let(:douglas) { create(:user, :male, first_name: 'Douglas') }
    let!(:ryto_mike_friendship) do
      create(:friendship, active_friend_id: ryto.id, passive_friend_id: mike.id, confirmed: true)
    end
    let!(:george_ryto_friendship) do
      create(:friendship, active_friend_id: george.id, passive_friend_id: ryto.id, confirmed: true)
    end
    let!(:anna_mike_request) do
      create(:friendship, active_friend_id: anna.id, passive_friend_id: mike.id)
    end
    let!(:anna_george_friendship) do
      create(:friendship, active_friend_id: anna.id, passive_friend_id: george.id, confirmed: true)
    end

    describe '#friends' do
      it 'returns collection of confirmed friends' do
        expect(ryto.friends).to include(mike, george)
      end
    end

    describe '#pending_sent_requests_to' do
      it 'returns collection of unconfirmed requested users' do
        expect(anna.pending_sent_requests_to.last).to eq(mike)
      end
    end

    describe '#pending_received_requests_from' do
      it 'returns collection of users whose request is unconfirmed' do
        expect(mike.pending_received_requests_from.last).to eq(anna)
      end
    end

    describe '#mutual_friends_with' do
      it 'returns collection of friends common with another user' do
        expect(ryto.mutual_friends_with(anna)).to include(george)
      end
    end

    describe '#paginated_friends method' do
      context 'page 1 with 2 results per page' do
        it 'shows first two friends' do
          expect(ryto.paginated_friends(1, 2)).to match([mike, george])
        end
      end
      context 'page 2 with 2 results per page' do
        it 'returns an empty collection' do
          expect(ryto.paginated_friends(2, 2).size).to be(0)
        end
      end
    end

    describe '#existing_friendship_or_request_with?' do
      context 'user has pending request to other user' do
        it 'returns true' do
          expect(anna.existing_friendship_or_request_with?(mike)).to be(true)
        end
      end

      context 'user has pending received request from other user' do
        it 'returns true' do
          expect(mike.existing_friendship_or_request_with?(anna)).to be(true)
        end
      end

      context 'user is friends with other user' do
        it 'returns true' do
          expect(ryto.existing_friendship_or_request_with?(mike)).to be(true)
        end
      end

      context 'user has no pending requests nor is friends with other user' do
        it 'returns false' do
          expect(ryto.existing_friendship_or_request_with?(douglas)).to be(false)
        end
      end
    end

    describe '#friendship_id_with' do
      context 'user has not sent to nor received friendship from user' do
        it 'returns nil' do
          expect(ryto.friendship_id_with(douglas)).to be(nil)
        end
      end

      context 'user is friends with other user ' do
        it 'returns friendship id' do
          expect(ryto.friendship_id_with(mike)).to eq(ryto_mike_friendship.id)
        end
      end

      context 'user has pending request from other user' do
        it 'returns friendship_id' do
          expect(mike.friendship_id_with(anna)).to eq(anna_mike_request.id)
        end
      end

      context 'user has pending request to other user' do
        it 'returns friendship id' do
          expect(anna.friendship_id_with(mike)).to eq(anna_mike_request.id)
        end
      end
    end
  end

  describe 'associations' do
    describe 'active_friendships and passive_friendships' do
      it {
        should have_many(:active_friendships)
          .dependent(:destroy)
          .with_foreign_key(:active_friend_id)
      }

      it {
        should have_many(:passive_friendships)
          .dependent(:destroy)
          .with_foreign_key(:passive_friend_id)
      }

      it {
        should have_many(:authored_posts)
          .with_foreign_key(:author_id)
          .dependent(:destroy)
      }

      it {
        should have_many(:authored_comments)
          .with_foreign_key(:commenter_id)
          .dependent(:destroy)
      }

      it {
        should have_many(:likes)
          .with_foreign_key(:liker_id)
          .dependent(:destroy)
      }
    end
  end

  describe 'posts related methods' do
    let(:archer) { create(:user, :male, first_name: 'Archer') }
    let(:william) { create(:user, :male, first_name: 'William') }
    let(:austin) { create(:user, :male, first_name: 'Austin') }

    before do
      create(:friendship, active_friend: archer, passive_friend: austin, confirmed: true)
      create(:friendship, active_friend: william, passive_friend: archer, confirmed: true)
      create(:friendship, active_friend: austin, passive_friend: william, confirmed: true)
      @post1 = create(:post, author: archer, postable: austin)
      @post2 = create(:post, postable: archer, author: william)
      @post3 = create(:post, author: william, postable: austin)
      @post4 = create(:post, author: austin, postable: william)
    end

    describe '#authored_posts and #received_posts' do
      it {
        should have_many(:authored_posts)
          .with_foreign_key(:author_id)
          .dependent(:destroy)
      }
      it {
        should have_many(:received_posts)
          .with_foreign_key(:postable_id)
          .dependent(:destroy)
      }
    end

    describe '#paginated_timeline_posts' do
      context 'posts per page is 2 and on page 1' do
        it 'shows post1 and post2' do
          expect(archer.paginated_timeline_posts(1, 2)).to include(@post1)
          expect(archer.paginated_timeline_posts(1, 2)).to include(@post2)
        end
      end
      context 'posts per page' do
        it 'shows an empty collection' do
          expect(archer.paginated_timeline_posts(2, 2).empty?).to be(true)
        end
      end
    end

    describe '#paginated_newsfeed_posts' do
      context 'page 1 of newsfeed' do
        it 'shows @posts 4 and 3' do
          page1_posts = archer.paginated_newsfeed_posts(1, 2)
          expect(page1_posts[0].content).to eq(@post4.content)
          expect(page1_posts[1].content).to eq(@post3.content)
        end
      end

      context 'page 2 of newsfeed' do
        it 'shows posts 2 and 1' do
          page2_posts = archer.paginated_newsfeed_posts(2, 2)
          expect(page2_posts[0].content).to eq(@post2.content)
          expect(page2_posts[1].content).to eq(@post1.content)
        end
      end
    end
  end
end
