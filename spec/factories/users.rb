FactoryBot.define do

  factory :user do
    first_name            { Faker::Name.first_name}
    last_name             { Faker::Name.last_name }
    email                 { (Faker::Internet.free_email name: first_name + " " + last_name) }
    password              { "password123" }
    password_confirmation { "password123" }

    trait :with_dogs do
      dogs { build_list :dog, 2 }
    end
  end

end