FactoryGirl.define do
  factory :role do

    factory :admin_role do
      name 'Admin'
    end

    factory :organizer_role do
      name 'Organizer'
    end

    factory :participant_role do
      name 'Participant'
    end
  end
end
