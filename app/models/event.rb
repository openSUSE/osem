class Event < ActiveRecord::Base
  include ActiveRecord::Transitions
  has_paper_trail
  attr_accessible :title, :subtitle, :abstract, :description, :event_type_id, :users_attributes,
                  :user, :proposal_additional_speakers, :track_id, :media_id, :media_type,
                  :require_registration, :difficulty_level_id

  acts_as_commentable

  after_create :set_week

  has_many :event_users, dependent: :destroy
  has_many :event_attachments, dependent: :destroy
  has_many :users, through: :event_users
  has_many :speakers, through: :event_users, source: :user
  has_many :votes
  has_many :voters, through: :votes, source: :user
  belongs_to :event_type

  has_and_belongs_to_many :registrations

  belongs_to :track
  belongs_to :room
  belongs_to :difficulty_level
  belongs_to :conference

  accepts_nested_attributes_for :event_users, allow_destroy: true
  accepts_nested_attributes_for :event_attachments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :users
  before_create :generate_guid

  validate :abstract_limit
  validate :biography_exists
  validates :title, presence: true
  validates :abstract, presence: true
  validates :media_type, allow_nil: true, inclusion: { in: Conference.media_types.values }

  scope :confirmed, -> { where(state: 'confirmed') }

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

  def voted?(event, user)
    event.votes.where('user_id = ?', user).first
  end

  def average_rating
    @total_rating = 0
    votes.each do |vote|
      @total_rating = @total_rating + vote.rating
    end
    @total = votes.size
    number_with_precision(@total_rating / @total.to_f, precision: 2, strip_insignificant_zeros: true)
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

    if room.nil?
      json[:room_guid] = nil
    else
      json[:room_guid] = room.guid
    end

    if track.nil?
      json[:track_color]  = '#ffffff'
    else
      json[:track_color] = track.color
    end

    if event_type.nil?
      json[:length] = 25
    else
      json[:length] = event_type.length
    end

    json
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end

  def process_confirmation
    if conference.email_settings.send_on_confirmed_without_registration?
      if conference.registrations.where(user_id: submitter.id).first.nil?
        Mailbot.confirm_reminder_mail(self).deliver
      end
    end
  end

  def process_acceptance(options)
    if conference.email_settings.send_on_accepted &&
        options[:send_mail].blank?
      Rails.logger.debug 'Sending event acceptance mail'
      Mailbot.acceptance_mail(self).deliver
    end
  end

  def process_rejection(options)
    if conference.email_settings.send_on_rejected &&
        options[:send_mail].blank?
      Rails.logger.debug 'Sending rejected mail'
      Mailbot.rejection_mail(self).deliver
    end
  end

  def abstract_word_count
    if abstract.nil?
      0
    else
      abstract.split.size
    end
  end

  def week
    created_at.strftime('%W').to_i
  end

  def self.get_state_color(state)
    # default azure
    result = '#00FFFF'
    case state
    when 'new' # blue
      result = '#0000FF'
    when 'withdrawn' # orange
      result = '#FF8000'
    when 'confirmed' # green
      result = '#00FF00'
    when 'unconfirmed' # yellow
      result = '#FFFF00'
    when 'rejected' # red
      result = '#FF0000'
    when 'canceled' # grey
      result = '#848484'
    end
    result
  end

  private

  def abstract_limit
    len = abstract.split.size
    max = event_type.maximum_abstract_length
    min = event_type.minimum_abstract_length

    if len < min
      errors.add(:abstract, "cannot have less than #{min} words")
    end

    errors.add(:abstract, "cannot have more than #{max} words") if len > max
  end

  def biography_exists
    errors.add(:user_biography, 'must be filled out') if submitter.biography_word_count == 0
  end

  def generate_guid
    begin
      guid = SecureRandom.urlsafe_base64
    end while self.class.where(guid: guid).exists?
    self.guid = guid
  end

  def set_week
    self.week = created_at.strftime('%W')
    save!
  end
end
