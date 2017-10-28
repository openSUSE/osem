FactoryGirl.define do
  factory :booth_request do
    booth
    user
    role 'responsible'

  end
end
