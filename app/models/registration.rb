class Registration < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference
  belongs_to :dietary_choice

  has_one :supporter_registration

  attr_accessible :person_id, :conference_id, :attending_social_events, :attending_with_partner,
                  :using_affiliated_lodging, :arrival, :departure, :person_attributes, :other_dietary_choice, :dietary_choice_id,
                  :handicapped_access_required, :supporter_registration_attributes

  accepts_nested_attributes_for :person
  accepts_nested_attributes_for :supporter_registration
end