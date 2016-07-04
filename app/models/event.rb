class Event < ActiveRecord::Base
  include ActiveRecord::Transitions
  has_paper_trail

  acts_as_commentable

  after_create :set_week

  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users
  has_many :speakers, through: :event_users, source: :user
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user
  has_many :commercials, as: :commercialable, dependent: :destroy
  belongs_to :event_type

  has_many :events_registrations
  has_many :registrations, through: :events_registrations

  belongs_to :track
  belongs_to :room
  belongs_to :difficulty_level
  belongs_to :program

  accepts_nested_attributes_for :event_users, allow_destroy: true
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

  scope :confirmed, -> { where(state: 'confirmed') }
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

  ##
  # Checkes if the event has a start_time and a room
  # ====Returns
  # * +true+ or +false+
  def scheduled?
    room && start_time ? true : false
  end

  def registration_possible?
    return false unless require_registration && state == 'confirmed'
    return true if max_attendees.nil?
    registrations.count < max_attendees
  end

  def voted?(event, user)
    event.votes.where('user_id = ?', user).first
  end

  def average_rating
    @total_rating = 0
    votes.each do |vote|
      @total_rating = @total_rating + vote.rating
    end
    @total = votes.size
    @total_rating > 0 ? number_with_precision(@total_rating / @total.to_f, precision: 2, strip_insignificant_zeros: true) : 0
  end

  def submitter
    result = event_users.where(event_role: 'submitter').first
    if !result.nil?
      result.user
    else
      user = nil
      # Perhaps the event_users haven't been saved, if this is a new proposal
      event_users.each do |u|
        if u.event_role == 'submitter'
          user = u.user
        end
      end
      user
    end
  end

  def as_json(options)
    json = super(options)

    json[:room_guid] = room.try(:guid)
    json[:track_color] = track.try(:color) || '#FFFFFF'
    json[:length] = event_type.try(:length) || 25

    json
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end

  def process_confirmation
    if program.conference.email_settings.send_on_confirmed_without_registration? &&
        program.conference.email_settings.confirmed_without_registration_body  &&
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
    color = {
      new:         '#0000FF', # blue
      withdrawn:   '#FF8000', # orange
      confirmed:   '#00FF00', # green
      unconfirmed: '#FFFF00', # yellow
      rejected:    '#FF0000', # red
      canceled:    '#848484'  # grey
    }[state.to_sym]

    color || '#00FFFF' # azure
  end

  def update_state(transition, mail = false, subject = false, send_mail = false, send_mail_param)
    alert = ''
    if mail && send_mail_param && subject && send_mail
      alert = 'Update Email Subject before Sending Mails'
    end
      begin
        if mail
          self.send(transition,
                    send_mail: send_mail_param)
        else
          self.send(transition)
        end
        self.save
      rescue Transitions::InvalidTransition => e
        alert = "Update state failed. #{e.message}"
      end
    alert
  end

  def speaker_names
    result = Set.new
    speakers.each do |speaker|
      result.add(speaker.name)
    end
    result.to_a.to_sentence
  end

  ##
  #
  # Returns +Hash+
  def progress_status
    {
      registered: self.program.conference.user_registered?(self.submitter),
      commercials: self.commercials.any?,
      biography: !self.submitter.biography.blank?,
      subtitle: !self.subtitle.blank?,
      track: (!self.track.blank? unless self.program.tracks.empty?),
      difficulty_level: !self.difficulty_level.blank?,
      title: true,
      abstract: true
    }.with_indifferent_access
  end

  ##
  # Returns the progress of the proposal's set up
  #
  # ====Returns
  # * +String+ -> Progress in Percent
  def calculate_progress
    result = self.progress_status
    (100 * result.values.count(true) / result.values.compact.count).to_s
  end

  ##
  # Returns end of the event
  #
  def end_time
    self.start_time + self.event_type.length.minutes
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
      break if !self.class.where(guid: guid).any?
    end
    self.guid = @guid
  end

  def set_week
    self.week = created_at.strftime('%W')
    save!
  end

  def before_end_of_conference
    errors.
        add(:created_at, "can't be after the conference end date!") if program.conference && program.conference.end_date &&
        (Date.today > program.conference.end_date)
  end
end
