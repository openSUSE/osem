FactoryGirl.define do
  factory :payment do
    user
    conference
    status 'unpaid'
    amount 1000
  end
end
