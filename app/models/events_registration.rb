class EventsRegistration < ActiveRecord::Base
  belongs_to :registration
  belongs_to :event

  has_one :user, through: :registration

  delegate :name, to: :registration
  delegate :email, to: :registration

  validates :event, :registration, presence: true
  validates :event, uniqueness: { scope: :registration }

  def send_event_registration_mail
    return unless send_email_on_new_event_registration?
    Mailbot.event_registration_email(event.program.conference, registration.user, event).deliver_later
  end

  def send_email_on_new_event_registration?
    event.program.conference.email_settings.send_on_new_event_registration &&
    event.program.conference.email_settings.new_event_registration_subject && event.program.conference.email_settings.new_event_registration_body
  end

  def send_email_on_deleted_event_registration_automatically?
    event.program.conference.email_settings.send_on_deleted_event_registration_automatically &&
    event.program.conference.email_settings.deleted_event_registration_automatically_subject && event.program.conference.email_settings.deleted_event_registration_automatically_body
  end
end
