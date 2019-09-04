# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:mike) { build(:user, first_name: 'Mike') }
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
    let(:ryto) { create(:user, username: 'ryto') }
    let(:mike) { create(:user, username: 'mike') }
    let(:anna) { create(:user, username: 'anna') }
    let(:george) { create(:user, username: 'george') }

    before do
      create(:friendship, active_friend_id: ryto.id, passive_friend_id: mike.id, confirmed: true)

      create(:friendship, active_friend_id: george.id, passive_friend_id: ryto.id, confirmed: true)

      create(:friendship, active_friend_id: anna.id, passive_friend_id: mike.id)

      create(:friendship, active_friend_id: anna.id, passive_friend_id: george.id, confirmed: true)
    end

    describe "ryto's #friends" do
      it 'includes mike and george' do
        expect(ryto.friends).to include(mike, george)
      end
    end

    describe "anna's last #pending_sent_requests_to" do
      it 'is mike' do
        expect(anna.pending_sent_requests_to.last).to eq(mike)
      end
    end

    describe "mike's last #pending_received_requests_from" do
      it 'is anna' do
        expect(mike.pending_received_requests_from.last).to eq(anna)
      end
    end

    describe "ryto's #mutual_friends_with(anna)" do
      it 'includes george' do
        expect(ryto.mutual_friends_with(anna, 1, 10)).to include(george)
      end
    end

    describe "ryto's #paginated_friends method" do
      context 'page 1 with 2 results per page' do
        it 'shows mike and george' do
          expect(ryto.paginated_friends(1, 2)).to match([mike, george])
        end
      end
      context 'page 2 with 2 results per page' do
        it 'returns an empty collection' do
          expect(ryto.paginated_friends(2, 2).size).to be(0)
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
    end
  end

  describe 'posts related methods' do
    let(:archer) { create(:user, username: 'archer') }
    let(:william) { create(:user, username: 'william') }
    let(:austin) { create(:user, username: 'austin') }

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

    describe '#timeline_posts' do
      context 'posts per page is 2 and on page 1' do
        it 'shows post1 and post2' do
          expect(archer.timeline_posts(1, 2)).to include(@post1)
          expect(archer.timeline_posts(1, 2)).to include(@post2)
        end
      end
      context 'posts per page' do
        it 'shows an empty collection' do
          expect(archer.timeline_posts(2, 2).empty?).to be(true)
        end
      end
    end

    describe '#newsfeed_posts' do
      it 'shows timeline_posts of user and timeline_posts of his friends' do
        expect(archer.newsfeed_posts.count).to be(4)
      end
    end
  end
end
