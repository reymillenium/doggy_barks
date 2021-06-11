require 'rails_helper'

RSpec.describe Like, type: :model, like: true do
  let(:described_object) { build :like }

  it "has a valid factory" do
    expect(FactoryBot.build(:like)).to be_valid
  end

  describe '#user' do
    it 'should be defined' do
      expect(described_object).to respond_to :user
    end

    it { is_expected.to belong_to(:user).class_name('User') }
  end

  describe '#dog' do
    it 'should be defined' do
      expect(described_object).to respond_to :user
    end

    it { is_expected.to belong_to(:dog).class_name('Dog') }
  end

  # Scopes:
  describe '.by_user' do
    let(:current_dogs) { 2.times.map { create :dog } }
    let(:current_user) { create :user }
    let(:other_user) { create :user }

    let!(:likes_created_by_current_user_and_one_dog) { 2.times.map { |index| create :like, user: current_user, dog: current_dogs[index] } }
    let!(:likes_created_by_other_user_and_one_dog) { 2.times.map { |index| create :like, user: other_user, dog: current_dogs[index] } }

    it 'should be defined' do
      expect(described_class).to respond_to :by_user
    end

    it 'should return an active record relationship' do
      expect(described_class.by_user(current_user)).to be_a ActiveRecord::Relation
    end

    it 'should return all the likes created by the current user' do
      expect(described_class.by_user(current_user.id)).to match_array likes_created_by_current_user_and_one_dog
    end

    it 'should not return any like when the current user is nil' do
      expect(described_class.by_user(nil)).to be_empty
    end
  end

  describe '.by_dog' do
    let(:current_users) { 2.times.map { create :user } }
    let(:current_dog) { create :dog }
    let(:other_dog) { create :dog }

    let!(:likes_created_by_current_dog_and_one_user) { 2.times.map { |index| create :like, dog: current_dog, user: current_users[index] } }
    let!(:likes_created_by_other_user_and_one_user) { 2.times.map { |index| create :like, dog: other_dog, user: current_users[index] } }

    it 'should be defined' do
      expect(described_class).to respond_to :by_dog
    end

    it 'should return an active record relationship' do
      expect(described_class.by_dog(current_dog)).to be_a ActiveRecord::Relation
    end

    it 'should return all the likes created by the current dog' do
      expect(described_class.by_dog(current_dog.id)).to match_array likes_created_by_current_dog_and_one_user
    end

    it 'should not return any like when the current dog is nil' do
      expect(described_class.by_dog(nil)).to be_empty
    end
  end
end