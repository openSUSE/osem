FactoryBot.define do
  factory :invite do
    conference
    emails { 'user@example.com' }
    end_date { '2019-08-12' }
    invite_for { (I18n.t 'booth').capitalize.to_s }
    user_id { 1 }
  end
end
