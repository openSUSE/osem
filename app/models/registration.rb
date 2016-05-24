class Registration < ActiveRecord::Base
  belongs_to :user
  belongs_to :conference

  has_and_belongs_to_many :events
  has_and_belongs_to_many :qanswers
  has_and_belongs_to_many :vchoices

  has_many :events_registrations
  has_many :events, through: :events_registrations, dependent: :destroy

  has_paper_trail ignore: [:updated_at, :week], meta: { conference_id: :conference_id }

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :qanswers

  delegate :name, to: :user
  delegate :email, to: :user
  delegate :nickname, to: :user
  delegate :affiliation, to: :user
  delegate :username, to: :user

  alias_attribute :other_needs, :other_special_needs

  validates :user, presence: true

  validates_uniqueness_of :user_id, scope: :conference_id, message: 'already Registered!'
  validate :registration_limit_not_exceed, on: :create
  validate :registration_to_events_only_if_present

  after_create :set_week, :subscribe_to_conference, :send_registration_mail
  after_destroy :destroy_purchased_tickets

  ##
  # Makes a list of events that includes (in that order):
  # Events that require registration, and registration to them is still possible
  # Events to which the user is already registered to
  # ==== RETURNS
  # * +Array+ -> [event_to_register_to, event_already_registered_to]
  def events_ordered
    (conference.program.events.with_registration_open - events) + events
  end

  def week
    created_at.strftime('%W').to_i
  end

  private

  ##
  # If the user registers to attend events that are already scheduled,
  # only allow registration to events if the user will be present
  # (based on arrival and departure attributes)
  # No validation if arrival/departure attributes are empty
  def registration_to_events_only_if_present
    if (arrival || departure) && events.pluck(:start_time).any?
      errors.add(:arrival, 'is too late! You cannot register for events that take place before your arrival') if events.pluck(:start_time).compact.map { |x| x < arrival }.any?

      errors.add(:departure, 'is too early! You cannot register for events that take place after your departure') if events.pluck(:start_time).compact.map { |x| x > departure }.any?
    end
  end

  def destroy_purchased_tickets
    ticket_purchased = TicketPurchase.where(conference_id: conference_id, user_id: user.id)
    ticket_purchased.destroy_all
  end

  def subscribe_to_conference
    Subscription.create(conference_id: conference.id, user_id: user.id)
  end

  def send_registration_mail
    if conference.email_settings.send_on_registration?
      Mailbot.registration_mail(conference, user).deliver_later
    end
  end

  def set_week
    self.week = created_at.strftime('%W')
    without_versioning do
      save!
    end
  end

  def registration_limit_not_exceed
    if conference.registration_limit > 0 && conference.registrations(:reload).count >= conference.registration_limit
      errors.add(:base, 'Registration limit exceeded')
    end
  end
end
