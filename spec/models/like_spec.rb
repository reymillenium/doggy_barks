require 'rails_helper'

RSpec.describe Like, type: :model do
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
end