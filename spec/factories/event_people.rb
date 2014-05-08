# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event_person do
    person

    Hash[EventPerson::ROLES].values.each do |role|
      factory role do
        event_role role
      end
    end
  end
end
