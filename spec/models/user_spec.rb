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
        expect(ryto.mutual_friends_with(anna, 1)).to include(george)
      end
    end

    describe "ryto's #friends_with_tags(anna)" do
      it "returns an array that includes george's data" do
        expect(anna.friends_with_tags(ryto, '1').last['id']).to eq(george.id)
      end
      it "returns an array with a hash that shows george as ryto's friend" do
        expect(anna.friends_with_tags(ryto, '1').first[:is_already_a_friend]).to be(true)
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

    describe 'active_friends and passive_friends' do
      it {
        should have_many(:active_friends)
          .through(:passive_friendships)
          .source(:active_friend)
          .dependent(:destroy)
      }

      it {
        should have_many(:passive_friends)
          .through(:active_friendships)
          .source(:passive_friend)
          .dependent(:destroy)
      }
    end
  end
end
