FactoryGirl.define do
  factory :resource do
    name { 'Resource' }
    quantity { 10 }
    used { 5 }
    conference
  end
end
