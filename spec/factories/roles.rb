FactoryGirl.define do
  factory :role do
    factory :organizer_role do
      name 'organizer'
    end

    factory :cfp_role do
      name 'cfp'
    end

    factory :info_desk_role do
      name 'info_desk'
    end

    factory :volunteers_coordinator_role do
      name 'volunteers_coordinator'
    end
  end
end
