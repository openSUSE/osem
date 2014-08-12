# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "example#{n}@example.com" }
    sequence(:name) { |n| "name#{n}" }
    password 'changeme'
    password_confirmation 'changeme'
    confirmed_at { Time.now }
    biography <<-EOS
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus enim
      nunc, venenatis non sapien convallis, dictum suscipit purus. Vestibulum
      sed tincidunt tortor. Fusce viverra nisi nisi, quis congue dui faucibus
      nec. Sed sodales suscipit nulla, accumsan porttitor augue ultrices vel.
      Quisque cursus facilisis consequat. Etiam volutpat ligula turpis, at
      gravida.
    EOS

    factory :participant do
      after(:create) { |user| user.role_ids = create(:participant_role).id }
    end

    factory :organizer_conference_1 do
      after(:create) { |user| user.role_ids = create(:organizer_conference_1_role).id }
    end

    factory :admin do
      is_admin true
    end
  end
end
