require 'rails_helper'

RSpec.describe User, type: :model, user: true do
  let(:described_object) { build :user }

  it "has a valid factory" do
    expect(FactoryBot.build(:user)).to be_valid
  end

  describe '#dogs' do
    let(:described_object) { build :user, :with_dogs }

    it 'should be defined' do
      expect(described_object).to respond_to :dogs
    end

    it 'should be a has_many relationship' do
      expect(described_object).to have_many(:dogs).class_name('Dog')
    end
  end

  describe '#email' do
    it 'should be defined' do
      expect(described_object).to respond_to :email
    end

    it 'should be required' do
      described_object.email = nil
      expect(described_object).to_not be_valid
    end
  end

  describe '#password' do
    it 'should be defined' do
      expect(described_object).to respond_to :password
    end

    it 'should be required' do
      described_object.password = nil
      expect(described_object).to_not be_valid
    end
  end

  describe '#first_name' do
    it 'should be defined' do
      expect(described_object).to respond_to :first_name
    end
  end

  describe '#last_name' do
    it 'should be defined' do
      expect(described_object).to respond_to :last_name
    end
  end
end