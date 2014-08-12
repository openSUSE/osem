class Role < ActiveRecord::Base
  attr_accessible :name, :description
  has_and_belongs_to_many :users
  belongs_to :resource, polymorphic: true

  scopify

  LABELS = ['Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker']
  ACTIONABLES = ['Organizer', 'CfP', 'Info Desk', 'Volunteers Coordinator']
end
