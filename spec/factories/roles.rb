FactoryGirl.define do
  factory :role do

    factory :organizer_role do
      name 'organizer'
    end

    factory :participant_role do
      name 'Participant'
    end

    factory :organizer_conference_1_role do
      name 'organizer'
      resource_type 'Conference'
      resource_id 1
    end
  end
end
