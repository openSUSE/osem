# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "example#{n}@example.com" }
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at Time.now

    factory :participant do
      after(:create) { |user| user.role_ids = create(:participant_role).id }
    end

    factory :admin do
      after(:create) { |user| user.role_ids = create(:admin_role).id }
    end

    factory :organizer do
      after(:create) { |user| user.role_ids = create(:organizer_role).id }
    end
  end
end
