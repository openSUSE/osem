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

  attr_accessible :user_id, :conference_id, :arrival, :departure, :user_attributes, :attended,
                  :other_dietary_choice, :dietary_choice_id, :social_event_ids, :other_special_needs,
                  :event_ids, :volunteer, :vchoice_ids, :qanswer_ids, :qanswers_attributes

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

  after_create :set_week, :subscribe_to_conference, :send_registration_mail

  def week
    created_at.strftime('%W').to_i
  end

  private

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
end
