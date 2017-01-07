# Read about factories at https://github.com/thoughtbot/factory_girl

# It is a feature of our app that first signed up user is admin. This property
# is set in a before create callback `setup_role` in user model.
# We want to override this behavior when we create user factories. We want
# `create(:user)` to create non-admin user by default. We are enforcing it
# with `after create` blocks in following factories.
#
# Following commands won't work:
#       `create(:user, is_admin: true)`
#       `create(:admin, is_admin: false)`
#
# For a non-admin user, use: `create(:user)`
# For an admin user, use: `create(:admin)

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "example#{n}@example.com" }
    sequence(:name) { |n| "name#{n}" }
    sequence(:username) { |n| "username#{n}" }
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

    after(:create) do |user|
      user.is_admin = false
      # save with bang cause we want change in DB and not just in object instance
      user.save!
    end

    factory :admin do
      # admin factory needs its own after create block or else after create
      # of user factory will override `is_admin` value.
      after(:create) do |user|
        user.is_admin = true
        user.save!
      end
    end
  end

  factory :user_xss, parent: :user do
    biography '<div id="divInjectedElement"></div>'
  end

end
