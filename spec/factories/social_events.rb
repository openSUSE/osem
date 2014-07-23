FactoryGirl.define do
  factory :social_event do
    title 'Example Social Event'
    description 'Lorem Ipsum Dolsum'
    date { Date.today }
    conference
  end

end
