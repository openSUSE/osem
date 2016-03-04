class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  scopify

  LABELS = ['Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker']
  ACTIONABLES = ['Organizer', 'CfP', 'Info Desk', 'Volunteers Coordinator']
end
