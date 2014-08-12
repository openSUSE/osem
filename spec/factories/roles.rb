FactoryGirl.define do
  factory :role do

    factory :participant_role do
      name 'participant'
    end

    factory :organizer_role do
      name 'organizer'
    end

    factory :organizer_conference_1_role do
      name 'organizer'
      resource_type 'Conference'
      resource_id 1
    end
  end
end
