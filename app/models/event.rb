# frozen_string_literal: true

class Event < ApplicationRecord
  include ActiveRecord::Transitions
  include RevisionCount
  has_paper_trail on: [:create, :update], ignore: [:updated_at, :guid, :week], meta: { conference_id: :conference_id }

  acts_as_commentable

  after_create :set_week

  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users

  has_many :speaker_event_users, -> { where(event_role: 'speaker') }, class_name: 'EventUser'
  has_many :speakers, through: :speaker_event_users, source: :user

  has_one :submitter_event_user, -> { where(event_role: 'submitter') }, class_name: 'EventUser'
  has_one  :submitter, through: :submitter_event_user, source: :user

  has_many :volunteer_event_users, -> { where(event_role: 'volunteer') }, class_name: 'EventUser'
  has_many :volunteers, through: :volunteer_event_users, source: :user

  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user
  has_many :commercials, as: :commercialable, dependent: :destroy
  has_many :surveys, as: :surveyable, dependent: :destroy
  belongs_to :event_type

  has_many :events_registrations
  has_many :registrations, through: :events_registrations
  has_many :event_schedules, dependent: :destroy

  belongs_to :track
  belongs_to :difficulty_level
  belongs_to :program
  belongs_to :room
  delegate :url, to: :room, allow_nil: true

  accepts_nested_attributes_for :event_users, allow_destroy: true
  accepts_nested_attributes_for :speakers, allow_destroy: true
  accepts_nested_attributes_for :users

  before_create :generate_guid

  validate :abstract_limit
  validate :before_end_of_conference, on: :create
  validates :title, presence: true
  validates :abstract, presence: true
  validates :event_type, presence: true
  validates :program, presence: true
  validates :max_attendees, numericality: { only_integer: true, greater_than_or_equal_to: 1, allow_nil: true }

  validate :max_attendees_no_more_than_room_size
  validate :valid_track

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :canceled, -> { where(state: 'canceled') }
  scope :withdrawn, -> { where(state: 'withdrawn') }
  scope :highlighted, -> { where(is_highlight: true) }

  state_machine initial: :new do
    state :new
    state :withdrawn
    state :unconfirmed
    state :confirmed
    state :canceled
    state :rejected

    event :restart do
      transitions to: :new, from: [:rejected, :withdrawn, :canceled]
    end
    event :withdraw do
      transitions to: :withdrawn, from: [:new, :unconfirmed, :confirmed]
    end
    event :accept do
      transitions to: :unconfirmed, from: [:new], on_transition: :process_acceptance
    end
    event :confirm do
      transitions to: :confirmed, from: :unconfirmed, on_transition: :process_confirmation
    end
    event :cancel do
      transitions to: :canceled, from: [:unconfirmed, :confirmed]
    end
    event :reject do
      transitions to: :rejected, from: [:new], on_transition: :process_rejection
    end
  end

  COLORS = {
    new:         '#0000FF', # blue
    withdrawn:   '#FF8000', # orange
    unconfirmed: '#FFFF00', # yellow
    confirmed:   '#00FF00', # green
    canceled:    '#848484', # grey
    rejected:    '#FF0000'  # red
  }.freeze

  ##
  # Checkes if the event has a start_time and a room for the selected schedule if there is any
  # ====Returns
  # * +true+ or +false+
  def scheduled?
    event_schedules.find_by(schedule_id: selected_schedule_id).present?
  end

  def registration_possible?
    return false unless require_registration && state == 'confirmed'
    return true if max_attendees.nil?

    registrations.count < max_attendees
  end

  ##
  # Finds the rating of the user for the event
  # ====Returns
  # * +integer+ -> the rating of the user for the event
  def user_rating(user)
    (vote = votes.find_by(user: user)) ? vote.rating : 0
  end

  ##
  # Checks if the event has votes
  # If a user is provided, it checks if the event has votes by the user
  # ====Returns
  # * +true+ -> If the event has votes (optionally, by the user)
  # * +false+ -> If the event does not have any votes (optionally, by the user)
  def voted?(user=nil)
    return votes.where(user: user).any? if user

    votes.any?
  end

  def average_rating
    @total_rating = 0
    votes.each do |vote|
      @total_rating += vote.rating
    end
    @total = votes.size
    @total_rating > 0 ? number_with_precision(@total_rating / @total.to_f, precision: 2, strip_insignificant_zeros: true) : 0
  end

  # get event speakers with the event sumbmitter at the first position
  # if the submitter is also a speaker for this event
  def speakers_ordered
    speakers_list = speakers.to_a

    if speakers_list.reject! { |speaker| speaker == submitter }
      speakers_list.unshift(submitter)
    end

    speakers_list
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end

  def process_confirmation
    if program.conference.email_settings.send_on_confirmed_without_registration? &&
        program.conference.email_settings.confirmed_without_registration_body &&
        program.conference.email_settings.confirmed_without_registration_subject
      if program.conference.registrations.where(user_id: submitter.id).first.nil?
        Mailbot.confirm_reminder_mail(self).deliver_later
      end
    end
  end

  def process_acceptance(options)
    if program.conference.email_settings.send_on_accepted &&
        program.conference.email_settings.accepted_body &&
        program.conference.email_settings.accepted_subject &&
        !options[:send_mail].blank?
      Mailbot.acceptance_mail(self).deliver_later
    end
  end

  def process_rejection(options)
    if program.conference.email_settings.send_on_rejected &&
        program.conference.email_settings.rejected_body &&
        program.conference.email_settings.rejected_subject &&
        !options[:send_mail].blank?
      Mailbot.rejection_mail(self).deliver_later
    end
  end

  def abstract_word_count
    abstract.to_s.split.size
  end

  def self.get_state_color(state)
    COLORS[state.to_sym] || '#00FFFF' # azure
  end

  def update_state(transition, mail = false, subject = false, send_mail = false, send_mail_param)
    alert = ''
    if mail && send_mail_param && subject && send_mail
      alert = 'Update Email Subject before Sending Mails'
    end
      begin
        if mail
          send(transition,
               send_mail: send_mail_param)
        else
          send(transition)
        end
        save
        # If the event was previously scheduled, and then withdrawn or cancelled
        # its event_schedule will have enabled set to false
        # If the event is now confirmed again, we want it to be available for scheduling
        Rails.logger.debug "transition is #{transition}"
        if transition == :confirm
          Rails.logger.debug "schedules #{EventSchedule.unscoped.where(event: self, enabled: false)}"
          EventSchedule.unscoped.where(event: self, enabled: false).destroy_all
        end
      rescue Transitions::InvalidTransition => e
        alert = "Update state failed. #{e.message}"
      end
    alert
  end

  def speaker_names
    speakers.map(&:name).join(', ')
  end

  # Returns emails of all the speaker belongs to a particular event
  def speaker_emails
    speakers.map(&:email).join(', ')
  end

  ##
  #
  # Returns +Hash+
  def progress_status
    {
      registered:       speakers.all? { |speaker| program.conference.user_registered? speaker },
      commercials:      commercials.any?,
      biographies:      speakers.all? { |speaker| !speaker.biography.blank? },
      subtitle:         !subtitle.blank?,
      track:            (!track.blank? unless program.tracks.empty?),
      difficulty_level: !difficulty_level.blank?,
      title:            true,
      abstract:         true
    }.with_indifferent_access
  end

  ##
  # Returns the progress of the proposal's set up
  #
  # ====Returns
  # * +String+ -> Progress in Percent
  def calculate_progress
    result = progress_status
    (100 * result.values.count(true) / result.values.compact.count).to_s
  end

  ##
  # Returns the room in which the event is scheduled
  #
  def room
    # We use try(:selected_schedule_id) because this function is used for
    # validations so program could not be present there
    if track.try(:self_organized?)
      track.room
    else
      event_schedules.find_by(schedule_id: program.try(:selected_schedule_id)).try(:room)
    end
  end

  ##
  # Returns the start time at which this event is scheduled
  #
  def time
    event_schedules.find_by(schedule_id: selected_schedule_id).try(:start_time)
  end

  ##
  # Returns the start time at which this event is scheduled
  #
  def happening_now?
    event_schedules.find_by(schedule_id: selected_schedule_id).try(:happening_now?)
  end


  ##
  # Returns true or false, if the event is already over or not
  #
  # ====Returns
  # * +true+ -> If the event is over
  # * +false+ -> If the event is not over yet
  def ended?
    event_schedule = event_schedules.find_by(schedule_id: selected_schedule_id)
    return false unless event_schedule

    event_schedule.end_time < Time.current
  end

  def conference
    program.conference
  end

  def <=>(other)
    time <=> other.time
  end

  private

  ##
  # Do not allow, for the event, more attendees than the size of the room
  def max_attendees_no_more_than_room_size
    return unless room && max_attendees_changed?

    errors.add(:max_attendees, "cannot be more than the room's capacity (#{room.size})") if max_attendees && (max_attendees > room.size)
  end

  def abstract_limit
    # If we don't have an event type, there is no need to count anything
    return unless event_type && abstract

    len = abstract.split.size
    max_words = event_type.maximum_abstract_length
    min_words = event_type.minimum_abstract_length

    errors.add(:abstract, "cannot have less than #{min_words} words") if len < min_words
    errors.add(:abstract, "cannot have more than #{max_words} words") if len > max_words
  end

  # TODO: create a module to be mixed into model to perform same operation
  # venue.rb has same functionality which can be shared
  # TODO: rename guid to UUID as guid is specifically Microsoft term
  def generate_guid
    loop do
      @guid = SecureRandom.urlsafe_base64
      break unless self.class.where(guid: guid).any?
    end
    self.guid = @guid
  end

  def set_week
    update!(week: created_at.strftime('%W'))
  end

  def before_end_of_conference
    errors
        .add(:created_at, "can't be after the conference end date!") if program.conference&.end_date &&
        (Date.today > program.conference.end_date)
  end

  def conference_id
    program.conference_id
  end

  ##
  # Allow only confirmed tracks that belong to the same program as the event
  #
  def valid_track
    return unless track&.program && program

    errors.add(:track, 'is invalid') unless track.confirmed? && track.program == program
  end

  ##
  # Return the id of the selected schedule
  #
  # ====Returns
  # * +Integer+ -> selected_schedule_id of self-organized track or program
  def selected_schedule_id
    if track.try(:self_organized?)
      track.selected_schedule_id
    else
      program.selected_schedule_id
    end
  end
end
