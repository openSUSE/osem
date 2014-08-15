FactoryGirl.define do
  factory :role do

    factory :organizer_role do
      name 'organizer'
    end

    factory :cfp_role do
      name 'cfp'
    end
  end
end
