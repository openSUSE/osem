class EventUser < ActiveRecord::Base
  # TODO Do we need these roles?
  ROLES = [['Speaker', 'speaker'], ['Submitter', 'submitter'], ['Moderator', 'moderator']]

  belongs_to :event
  belongs_to :user
end
