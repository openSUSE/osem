# frozen_string_literal: true

# == Schema Information
#
# Table name: registrations
#
#  id                       :bigint           not null, primary key
#  accepted_code_of_conduct :boolean
#  attended                 :boolean          default(FALSE)
#  other_special_needs      :text
#  volunteer                :boolean
#  week                     :integer
#  created_at               :datetime
#  updated_at               :datetime
#  conference_id            :integer
#  user_id                  :integer
#
class Registration < ApplicationRecord
  require 'csv'
  belongs_to :user
  belongs_to :conference

  has_and_belongs_to_many :qanswers
  has_and_belongs_to_many :vchoices

  has_many :events_registrations
  has_many :events, through: :events_registrations, dependent: :destroy

  has_paper_trail ignore: %i(updated_at week), meta: { conference_id: :conference_id }

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :qanswers

  delegate :name, to: :user
  delegate :email, to: :user
  delegate :nickname, to: :user
  delegate :affiliation, to: :user
  delegate :username, to: :user

  alias_attribute :other_needs, :other_special_needs

  validates :user, presence: true

  validates :user_id, uniqueness: { scope: :conference_id, message: 'already Registered!' }
  validate :registration_limit_not_exceed, on: :create
  validates :accepted_code_of_conduct, acceptance: {
    if: -> { conference.try(:code_of_conduct).present? }
  }

  validate :user_has_registration_ticket, if: -> { conference.registration_ticket_required? }

  after_create :set_week, :subscribe_to_conference, :send_registration_mail

  ##
  # Makes a list of events that includes (in that order):
  # Events that require registration, and registration to them is still possible
  # Events to which the user is already registered to
  # ==== RETURNS
  # * +Array+ -> [event_to_register_to, event_already_registered_to]
  def events_ordered
    (conference.program.events.with_registration_open - events) + events
  end

  private

  def subscribe_to_conference
    Subscription.create(conference_id: conference.id, user_id: user.id)
  end

  def send_registration_mail
    if conference.email_settings.send_on_registration?
      Mailbot.registration_mail(conference, user).deliver_later
    end
  end

  def set_week
    update!(week: created_at.strftime('%W'))
  end

  def registration_limit_not_exceed
    if conference.registration_limit > 0 && conference.registrations.count >= conference.registration_limit
      errors.add(:base, 'Registration limit exceeded')
    end
  end

  def user_has_registration_ticket
    return if conference.registration_ticket_required? &&
              TicketPurchase.where(user: user, ticket: conference.registration_tickets).paid.any?

    errors.add(:base, 'You must purchase a registration ticket before registering')
    if TicketPurchase.where(user: user, ticket: conference.registration_tickets).unpaid.any?
      errors.add(:base, 'You currently have a ticket with an unfinished purchase')
    end
  end
end
