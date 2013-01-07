class EventPerson < ActiveRecord::Base
  attr_accessible :event, :person, :person_id, :event_role
  # TODO Do we need these roles?
  ROLES = [["Speaker","speaker"], ["Submitter","submitter"], ["Moderator","moderator"]]

  belongs_to :event
  belongs_to :person
end