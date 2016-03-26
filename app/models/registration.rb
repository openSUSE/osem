class Registration < ActiveRecord::Base
  belongs_to :user
  belongs_to :conference
  belongs_to :dietary_choice

  has_and_belongs_to_many :social_events
  has_and_belongs_to_many :events
  has_and_belongs_to_many :qanswers
  has_and_belongs_to_many :vchoices

  has_many :events_registrations
  has_many :workshops, through: :events_registrations, source: :event

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :social_events
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

  after_create :set_week, :subscribe_to_conference, :send_registration_mail
  after_destroy :destroy_purchased_tickets

  def week
    created_at.strftime('%W').to_i
  end

  private

  def destroy_purchased_tickets
    ticket_purchased = TicketPurchase.where(conference_id: conference_id, user_id: user.id)
    ticket_purchased.destroy_all
  end

  def subscribe_to_conference
    Subscription.create(conference_id: conference.id, user_id: user.id)
  end

  def send_registration_mail
    if conference.email_settings.send_on_registration?
      Mailbot.delay.registration_mail(conference, user)
    end
  end

  def set_week
    self.week = created_at.strftime('%W')
    save!
  end

  def registration_limit_not_exceed
    if conference.registration_limit > 0 && conference.registrations(:reload).count >= conference.registration_limit
      errors.add(:base, 'Registration limit exceeded')
    end
  end
end
