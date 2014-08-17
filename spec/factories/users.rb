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

    factory :admin do
      is_admin true
    end

    factory :organizer do
      after(:create) { |user| user.role_ids = create(:organizer_role).id }
    end

    factory :deleted_user do
      after(:create) { |user| user.email = 'deleted@localhost.osem', user.name = 'User deleted', user.biography = 'Data is no longer available for deleted user.' }
    end
  end
end
