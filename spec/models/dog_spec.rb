require 'rails_helper'

RSpec.describe Dog, type: :model do
  let(:described_object) { build :dog }

  it "has a valid factory" do
    expect(FactoryBot.build(:dog)).to be_valid
  end

  describe '#user' do
    it 'should be defined' do
      expect(described_object).to respond_to :user
    end

    # it 'should be a optional belongs_to relationship' do
    #   expect(described_object).to belong_to(:user).class_name('User').optional(true)
    # end
    it { is_expected.to belong_to(:user).class_name('User').optional(true) }
  end

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
end