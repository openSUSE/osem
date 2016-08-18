FactoryGirl.define do
  factory :payment do
    user
    conference
    status 'unpaid'
  end
end
