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

    describe 'authored_posts and received_posts' do
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
  end
end
