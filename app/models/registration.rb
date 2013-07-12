class Registration < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
  belongs_to :dietary_choice

  has_one :supporter_registration
  has_and_belongs_to_many :social_events
  has_and_belongs_to_many :events

  attr_accessible :person_id, :conference_id, :attending_social_events, :attending_with_partner,
                  :using_affiliated_lodging, :arrival, :departure, :person_attributes, :other_dietary_choice, :dietary_choice_id,
                  :handicapped_access_required, :supporter_registration_attributes, :social_event_ids, :other_special_needs,
                  :event_ids, :attended

  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :supporter_registration
  accepts_nested_attributes_for :social_events
end
