FactoryGirl.define do
  factory :supporter_level do
    title 'Example Supporter Level'
    url 'www.example.com'
    amount '2200'
    price_currency 'USD'
    conference
  end

end