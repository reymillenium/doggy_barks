require 'rails_helper'

RSpec.describe Dog, type: :model do
  let(:described_object) { build :dog }

  it "has a valid factory" do
    expect(FactoryBot.build(:dog)).to be_valid
  end

  # Relations:

  describe '#user' do
    it 'should be defined' do
      expect(described_object).to respond_to :user
    end

    it { is_expected.to belong_to(:user).class_name('User').optional(true) }
  end

  # Properties:

  describe '#name' do
    it 'should be defined' do
      expect(described_object).to respond_to :name
    end

    it 'should be required' do
      described_object.name = nil
      expect(described_object).to_not be_valid
    end
  end

  describe '#description' do
    it 'should be defined' do
      expect(described_object).to respond_to :description
    end

    it 'should not be required' do
      described_object.description = nil
      expect(described_object).to be_valid
    end
  end

  # Scopes:

  describe '.owned_by' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }

    it 'should be defined' do
      expect(described_class).to respond_to :owned_by
    end

    it 'should return an active record relationship' do
      expect(described_class.owned_by(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs created by the current user' do
      expect(described_class.owned_by(current_user.id)).to match_array dogs_created_by_current_user
    end

    it 'should not return any dog when the current user is nil' do
      expect(described_class.owned_by(nil)).to be_empty
    end
  end

  describe '.not_owned_by' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_class).to respond_to :not_owned_by
    end

    it 'should return an active record relationship' do
      expect(described_class.not_owned_by(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs not created by the current user' do
      expect(described_class.not_owned_by(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_other_user + dogs_already_existing_without_owner).sort_by(&:id)
    end

    it 'should return all the dogs owned by somebody, no matter who, when the current user is nil (all except the free dogs)' do
      expect(described_class.not_owned_by(nil).sort_by(&:id)).to match_array (dogs_created_by_current_user + dogs_created_by_other_user).sort_by(&:id)
    end
  end

  describe '.free' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_class).to respond_to :free
    end

    it 'should return an active record relationship' do
      expect(described_class.free).to be_a ActiveRecord::Relation
    end

    it 'should return all the free dogs (those not created by the current user nor by any other one either)' do
      expect(described_class.free.sort_by(&:id)).to match_array (dogs_already_existing_without_owner).sort_by(&:id)
    end
  end

  describe '.owned_by_or_free' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_class).to respond_to :owned_by_or_free
    end

    it 'should return an active record relationship' do
      expect(described_class.owned_by_or_free(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs created by the current user and also the free dogs' do
      expect(described_class.owned_by_or_free(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_current_user + dogs_already_existing_without_owner).sort_by(&:id)
    end

    # it 'should not return any dog when the current user is nil' do
    # expect(described_class.owned_by_or_free(nil)).to be_empty
    it 'should return only free dogs when the current user is nil' do
      expect(described_class.owned_by_or_free(nil).sort_by(&:id)).to match_array (dogs_already_existing_without_owner).sort_by(&:id)
    end
  end

  describe '.not_owned_by_nor_free' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_class).to respond_to :not_owned_by_nor_free
    end

    it 'should return an active record relationship' do
      expect(described_class.not_owned_by_nor_free(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs created by other users' do
      expect(described_class.not_owned_by_nor_free(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_other_user).sort_by(&:id)
    end

    # it 'should not return any dog when the current user is nil' do
    # expect(described_class.not_owned_by_nor_free(nil)).to be_empty
    it 'should return the dogs owned by the current user and those owned bu other users too, when the given user is nil' do
      expect(described_class.not_owned_by_nor_free(nil).sort_by(&:id)).to match_array (dogs_created_by_current_user + dogs_created_by_other_user).sort_by(&:id)
    end
  end

  describe '.editable_by' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }

    it 'should be defined' do
      expect(described_class).to respond_to :editable_by
    end

    it 'should return an active record relationship' do
      expect(described_class.editable_by(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs created by the current user (only their own can be edited)' do
      expect(described_class.editable_by(current_user.id)).to match_array dogs_created_by_current_user
    end

    it 'should not return any dog when the current user is nil' do
      expect(described_class.editable_by(nil)).to be_empty
    end
  end

  describe '.likeable_by' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_class).to respond_to :likeable_by
    end

    it 'should return an active record relationship' do
      expect(described_class.likeable_by(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs not created by the current user (only other dogs can be liked, not their own)' do
      expect(described_class.likeable_by(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_other_user + dogs_already_existing_without_owner).sort_by(&:id)
    end

    it 'should return all the dogs owned by somebody, no matter who, when the current user is nil (all except the free dogs)' do
      expect(described_class.likeable_by(nil).sort_by(&:id)).to match_array (dogs_created_by_current_user + dogs_created_by_other_user).sort_by(&:id)
    end
  end

  describe '.liked_by_user' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    let!(:likes_created_by_current_user_and_for_other_dogs_and_free_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_other_user[index] }
      2.times.map { |index| create :like, user: current_user, dog: dogs_already_existing_without_owner[index] }
    }

    it 'should be defined' do
      expect(described_class).to respond_to :liked_by_user
    end

    it 'should return an active record relationship' do
      expect(described_class.liked_by_user(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs already liked by the current user (only other dogs can be liked, with or without owner, not their own)' do
      expect(described_class.liked_by_user(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_other_user + dogs_already_existing_without_owner).sort_by(&:id)
    end

    it 'should not return any dog when the current user is nil' do
      expect(described_class.liked_by_user(nil).sort_by(&:id)).to be_empty
    end
  end

  describe '.not_liked_by_user' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    let!(:likes_created_by_current_user_and_for_other_dogs_and_free_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_other_user[index] }
      2.times.map { |index| create :like, user: current_user, dog: dogs_already_existing_without_owner[index] }
    }

    it 'should be defined' do
      expect(described_class).to respond_to :not_liked_by_user
    end

    it 'should return an active record relationship' do
      expect(described_class.not_liked_by_user(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs that have not been liked yet by the current user (only other dogs can be liked, with or without owner, not their own)' do
      expect(described_class.not_liked_by_user(current_user.id).sort_by(&:id)).to match_array (dogs_created_by_current_user).sort_by(&:id)
    end

    it 'should return all the dogs, either liked or not, when the current user is nil' do
      expect(described_class.not_liked_by_user(nil).sort_by(&:id)).to match_array (dogs_created_by_current_user + dogs_created_by_other_user + dogs_already_existing_without_owner).sort_by(&:id)
    end
  end

  describe '.ordered_by_likes' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    let!(:likes_created_by_current_user_and_for_other_dogs_and_free_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_other_user[index] }
      2.times.map { |index| create :like, user: current_user, dog: dogs_already_existing_without_owner[index] }
    }

    # Adding some likes to previously liked dogs (to test if the special ordering works)
    let!(:likes_created_by_other_user_and_for_some_of_previous_liked_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_current_user[index] }
    }

    # Gets all the liked dogs, ordered by the amount of likes on the last hour:
    liked_dogs_ordered_desc_ids = Dog.all.select { |dog| dog.last_hour_likes_amount > 0 }.sort_by(&:last_hour_likes_amount).reverse.pluck(:id)
    # Gets all the none liked dogs, ordered by id as default:
    none_liked_dogs_ids = Dog.all.select { |dog| dog.last_hour_likes_amount == 0 }.pluck(:id)
    # First the liked dogs (ordered desc) and then the not liked yet dogs (ordered by id as usual):
    desired_order_ids = liked_dogs_ordered_desc_ids + none_liked_dogs_ids

    let!(:applicable_scope) { Dog.order_as_specified(id: desired_order_ids) }

    it 'should be defined' do
      expect(described_class).to respond_to :ordered_by_likes
    end

    it 'should return an active record relationship' do
      expect(described_class.ordered_by_likes).to be_a ActiveRecord::Relation
    end

    it 'should return all the dogs, ordered this way: First the liked dogs (ordered desc) and then the not liked yet dogs (ordered by id as usual)' do
      expect(described_class.ordered_by_likes).to match_array applicable_scope
    end
  end

  # Instance methods:

  describe '#editable_by?' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_object).to respond_to :editable_by?
    end

    context 'when is a free dog' do
      # The common described_object is a free dog
      # let(:described_object) { dogs_already_existing_without_owner.sample }

      it 'should return false when no defined user is given' do
        expect(described_object.editable_by?(nil)).to be_falsey
      end

      it 'should return false when any defined user is given' do
        expect(described_object.editable_by?(current_user)).to be_falsey
      end
    end

    context 'when is not a free dog' do
      let(:described_object) { dogs_created_by_current_user.sample }

      it 'should return false when no defined user is given' do
        expect(described_object.editable_by?(nil)).to be_falsey
      end

      it 'should return true when his own owner is given' do
        expect(described_object.editable_by?(current_user)).to be_truthy
      end

      it 'should return false when another user is given' do
        expect(described_object.editable_by?(other_user)).to be_falsey
      end
    end
  end

  describe '#destroyable_by?' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    it 'should be defined' do
      expect(described_object).to respond_to :destroyable_by?
    end

    context 'when is a free dog' do
      # The common described_object is a free dog
      # let(:described_object) { dogs_already_existing_without_owner.sample }

      it 'should return false when no defined user is given' do
        expect(described_object.destroyable_by?(nil)).to be_falsey
      end

      it 'should return false when any defined user is given' do
        expect(described_object.destroyable_by?(current_user)).to be_falsey
      end
    end

    context 'when is not a free dog' do
      let(:described_object) { dogs_created_by_current_user.sample }

      it 'should return false when no defined user is given' do
        expect(described_object.destroyable_by?(nil)).to be_falsey
      end

      it 'should return true when his own owner is given' do
        expect(described_object.destroyable_by?(current_user)).to be_truthy
      end

      it 'should return false when another user is given' do
        expect(described_object.destroyable_by?(other_user)).to be_falsey
      end
    end
  end

  describe '#likeable_by?' do
    let(:current_user) { create :user }
    let(:other_user) { create :user }
    let(:third_user_that_dont_likes_dogs) { create :user }

    let!(:dogs_created_by_current_user) { 2.times.map { create :dog, user: current_user } }
    let!(:dogs_created_by_other_user) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner) { 2.times.map { create :dog } }

    # let!(:dogs_created_by_current_user_and_liked) { 2.times.map { create :dog, user: current_user } } # A user can not like his own dog
    let!(:dogs_created_by_other_user_and_liked) { 2.times.map { create :dog, user: other_user } }
    let!(:dogs_already_existing_without_owner_and_liked) { 2.times.map { create :dog } }

    let!(:likes_created_by_current_user_and_for_other_dogs_and_free_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_other_user_and_liked[index] }
      2.times.map { |index| create :like, user: current_user, dog: dogs_already_existing_without_owner_and_liked[index] }
    }

    # Adding some likes to previously liked dogs (to test if the special ordering works)
    let!(:likes_created_by_other_user_and_for_some_of_previous_liked_dogs) {
      2.times.map { |index| create :like, user: current_user, dog: dogs_created_by_current_user[index] }
    }

    it 'should be defined' do
      expect(described_object).to respond_to :likeable_by?
    end

    context 'when is a free dog' do
      # The common described_object is a free dog
      # let(:described_object) { dogs_already_existing_without_owner.sample }

      it 'should return false when no defined user is given' do
        expect(described_object.likeable_by?(nil)).to be_falsey
      end

      context 'when it has not been liked yet' do
        it 'should return true when any user is given' do
          expect(described_object.likeable_by?(current_user)).to be_falsey
          expect(described_object.likeable_by?(other_user)).to be_falsey
        end
      end

      context 'when it has been already liked' do
        let(:described_object) { dogs_already_existing_without_owner_and_liked.sample }

        it 'should return false when is given the user that liked it' do
          expect(described_object.likeable_by?(current_user)).to be_falsey
        end

        it 'should return true when is given a user that did not liked it' do
          expect(described_object.likeable_by?(other_user)).to be_truthy
        end
      end
    end

    context 'when is not a free dog' do
      context 'when it has not been liked yet' do
        let(:described_object) { dogs_created_by_current_user.sample }

        it 'should return false when no defined user is given' do
          expect(described_object.likeable_by?(nil)).to be_falsey
        end

        it 'should return false when its owner is given' do
          expect(described_object.likeable_by?(current_user)).to be_falsey
        end

        it 'should return true when another user is given' do
          expect(described_object.likeable_by?(other_user)).to be_truthy
        end
      end

      context 'when it has been already liked' do
        let(:described_object) { dogs_created_by_other_user_and_liked.sample }

        it 'should return false when no defined user is given' do
          expect(described_object.likeable_by?(nil)).to be_falsey
        end

        it 'should return false when is given the user that liked it' do
          expect(described_object.likeable_by?(current_user)).to be_falsey
        end

        it 'should return true when is given a user that did not liked it' do
          expect(described_object.likeable_by?(third_user_that_dont_likes_dogs)).to be_truthy
        end
      end
    end
  end
end