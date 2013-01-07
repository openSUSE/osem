class Registration < ActiveRecord::Base
  belongs_to :person
  belongs_to :conference

  attr_accessible :person_id, :conference_id, :attending_social_events, :attending_social_events_with_partner,
                  :using_affiliated_lodging, :arrival, :departure, :person_attributes
  accepts_nested_attributes_for :person

end