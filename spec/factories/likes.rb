FactoryBot.define do
  factory :like do
    dog    { build :dog }
    user   { build :user }
  end
end
