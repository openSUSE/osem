FactoryGirl.define do
  factory :vday do
    day { Date.today }
    description 'Lorem Ipsum dolsum'
    conference
  end

end
