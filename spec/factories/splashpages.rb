# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :splashpage do
    public  false

    factory :full_splashpage do
      public true
      include_tracks true
      include_program true
      include_social_media true
      include_venue true
      include_tickets true
      include_registrations true
      include_sponsors true
      include_lodgings true
      include_cfp true
    end
  end
end
