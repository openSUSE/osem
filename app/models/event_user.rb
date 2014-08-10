class EventUser < ActiveRecord::Base
  attr_accessible :event, :user, :user_id, :event_role
  # TODO Do we need these roles?
  ROLES = [['Speaker', 'speaker'], ['Submitter', 'submitter'], ['Moderator', 'moderator']]

  belongs_to :event
  belongs_to :user

  def self.create_deleted_eventuser(user,event)
    event_role = event.event_users.where(user: user).first.event_role
    event.event_users.where(user: user).destroy_all
    EventUser.create(user: User.find_by(email: 'deleted@localhost.osem'), event: event, event_role: event_role)
  end
end
