class EventsRegistration < ActiveRecord::Base
  belongs_to :registration
  belongs_to :event

  has_one :user, through: :registration

  delegate :name, to: :registration
  delegate :email, to: :registration

  validates :event, :registration, presence: true
  validates :event, uniqueness: { scope: :registration }
end
