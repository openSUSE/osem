class EventsRegistration < ActiveRecord::Base
  belongs_to :registration
  belongs_to :event

  has_one :user, through: :registration

  has_paper_trail meta: { conference_id: :conference_id }

  delegate :name, to: :registration
  delegate :email, to: :registration

  validates :event, :registration, presence: true
  validates :event, uniqueness: { scope: :registration }

  private

  def conference_id
    registration.conference_id
  end
end
