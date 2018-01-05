# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_user do
    user

    Hash[EventUser::ROLES].each_value do |role|
      factory role do
        event_role role
      end
    end
  end
end
