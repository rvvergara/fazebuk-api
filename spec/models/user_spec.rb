# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:ryto) { create(:user, :male, first_name: 'Ryto') }
  let(:mike) { create(:user, :male, first_name: 'Mike') }
  let(:anna) { create(:user, :female, first_name: 'Anna') }
  let(:george) { create(:user, :male, first_name: 'George') }
  let(:douglas) { create(:user, :male, first_name: 'Douglas') }
  let!(:ryto_mike_friendship) do
    create(:friendship, :confirmed, active_friend_id: ryto.id, passive_friend_id: mike.id)
  end
  let!(:george_ryto_friendship) do
    create(:friendship, :confirmed, active_friend: george, passive_friend: ryto)
  end
  let!(:george_mike_friendship) do
    create(:friendship, :confirmed, active_friend: george, passive_friend: mike)
  end
  let!(:anna_mike_request) do
    create(:request, active_friend: anna, passive_friend: mike)
  end
  let!(:anna_george_friendship) do
    create(:friendship, :confirmed, active_friend: anna, passive_friend: george)
  end
  let!(:post1) { create(:post, author: ryto, postable: mike) }
  let!(:post2) { create(:post, author: ryto, postable: george) }
  let!(:post3) { create(:post, author: george, postable: mike) }
  let!(:post4) { create(:post, author: mike, postable: george) }
  let!(:post5) { create(:post, author: anna, postable: george) }
  let!(:post6) { create(:post, author: mike, postable: anna) }
  let(:gerard) { create(:user, :male, :with_profile_images, first_name: 'Gerard') }
  let(:hunter) { create(:user, :male, :with_cover_images, first_name: 'Hunter') }

  after :all do
    remove_uploaded_files
  end

  describe 'validations' do
    let(:joe) { build(:user, :male, first_name: 'Joe') }
    context 'complete basic info' do
      it 'is valid' do
        expect(joe).to be_valid
      end
    end

    context 'first_name absent' do
      it 'is invalid' do
        joe.first_name = nil
        expect(joe).to_not be_valid
      end
    end

    context 'duplicate username' do
      it 'is invalid' do
        mike2 = build(:user, :male, username: 'mike')

        mike2.valid?

        expect(mike2.errors['username']).to include('has already been taken')
      end
    end

    context 'username is all caps' do
      it 'is downcased' do
        doug = build(:user, :male, username: 'DOUG')

        doug.valid?
        expect(doug.username).to eq(doug.username.downcase)
      end
    end
  end

  describe 'friendship methods' do
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

  describe 'posts related methods' do
    describe '#timeline posts' do
      context 'user authored 2 posts' do
        it {
          expect(ryto.timeline_posts.count).to be(2)
        }
        it {
          expect(ryto.timeline_posts).to match([post2, post1])
        }
      end

      context 'user authored 2 and received 2 posts' do
        it {
          expect(mike.timeline_posts.count).to be(4)
        }
        it {
          expect(mike.timeline_posts).to match([post6, post4, post3, post1])
        }
      end
    end

    describe '#paginated_timeline_posts' do
      context 'each page has 2 posts max' do
        context 'page1' do
          it 'shows 2 posts' do
            expect(mike.paginated_timeline_posts(1, 2)).to match([post6, post4])
          end
        end

        context 'page 2' do
          it 'shows 1 post' do
            expect(mike.paginated_timeline_posts(2, 2)).to match([post3, post1])
          end
        end

        context 'page 3' do
          it 'returns an empty collection' do
            expect(mike.paginated_timeline_posts(3, 2)).to match([])
          end
        end
      end
    end

    describe '#newsfeed posts' do
      it {
        expect(ryto.newsfeed_posts).to match([post6, post5, post4, post3, post2, post1])
      }
      it {
        expect(ryto.newsfeed_posts.count).to be(6)
      }
    end

    describe '#paginated_newsfeed_posts' do
      context '4 max posts per page' do
        context 'page 1' do
          it 'shows 4 posts' do
            expect(ryto.paginated_newsfeed_posts(1, 4)).to match([post6, post5, post4, post3])
          end
        end

        context 'page 2' do
          it 'shows 2 posts' do
            expect(ryto.paginated_newsfeed_posts(2, 4)).to match([post2, post1])
          end
        end

        context 'page 3' do
          it 'shows empty collection' do
            expect(ryto.paginated_newsfeed_posts(3, 4)).to match([])
          end
        end
      end
    end

    describe '#liked?' do
      let!(:like) { create(:like, :for_post, liker: ryto, likeable: post3) }

      it {
        expect(ryto.liked?(post3)).to be(true)
      }
      it {
        expect(ryto.liked?(post2)).to be(false)
      }
    end
  end

  describe 'private method effects' do
    describe '#downcase effect' do
      context 'all caps username input' do
        it 'downcases username' do
          kobe = build(:user, :male, username: 'KOBE')

          kobe.valid?

          expect(kobe.username).to eq('kobe')
        end
      end

      context 'all caps email input' do
        it 'downcases email' do
          ricci = build(:user, :male, email: 'RICCI@gmail.com')

          ricci.valid?

          expect(ricci.email).to eq('ricci@gmail.com')
        end
      end
    end

    describe '#assign_profile_pic' do
      it 'assigns profile pic to user' do
        profile_img_url = rails_blob_path(gerard.profile_images.last, only_path: true)

        gerard.update(username: 'gerry')

        expect(gerard.profile_pic).to eq(profile_img_url)
      end
    end

    describe '#assign_cover_pic' do
      it 'assigns cover pic to user' do
        cover_img_url = rails_blob_path(hunter.cover_images.last, only_path: true)

        hunter.update(username: 'the-game')

        expect(hunter.cover_pic).to eq(cover_img_url)
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
        should have_many(:received_posts)
          .with_foreign_key(:postable_id)
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
end
