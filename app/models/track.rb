class Track < ActiveRecord::Base
  include ActiveRecord::Transitions
  include RevisionCount

  resourcify :roles, dependent: :delete_all

  belongs_to :program
  belongs_to :submitter, class_name: 'User'
  belongs_to :room
  has_many :events, dependent: :nullify

  has_paper_trail only: [:name, :description, :color], meta: { conference_id: :conference_id }

  before_create :generate_guid
  validates :name, presence: true
  validates :color, format: /\A#[0-9A-F]{6}\z/
  validates :short_name,
            presence: true,
            format: /\A[a-zA-Z0-9_-]*\z/,
            uniqueness: {
              scope: :program
            }
  validates :state,
            presence: true,
            inclusion: { in: %w(new to_accept accepted confirmed to_reject rejected canceled withdrawn) },
            if: :self_organized?
  validates :cfp_active, inclusion: { in: [true, false] }, if: :self_organized?
  validates :start_date, presence: true, if: :accepted_or_confirmed?
  validates :end_date, presence: true, if: :accepted_or_confirmed?
  validates :room, presence: true, if: :accepted_or_confirmed?
  validate :valid_dates, if: :accepted_or_confirmed?

  before_validation :capitalize_color

  state_machine initial: :pending do
    state :new
    state :to_accept
    state :accepted
    state :confirmed
    state :to_reject
    state :rejected
    state :canceled
    state :withdrawn

    event :restart do
      transitions to: :new, from: [:rejected, :withdrawn, :canceled]
    end
    event :readiness_to_accept do
      transitions to: :to_accept, from: [:new]
    end
    event :accept do
      transitions to: :accepted, from: [:new, :to_accept], on_transition: :create_organizer_role
    end
    event :confirm do
      transitions to: :confirmed, from: [:accepted], on_transition: :assign_role_to_submitter
    end
    event :readiness_to_reject do
      transitions to: :to_reject, from: [:new]
    end
    event :reject do
      transitions to: :rejected, from: [:new, :to_reject]
    end
    event :cancel do
      transitions to: :canceled, from: [:to_accept, :to_reject, :accepted, :confirmed], on_transition: :revoke_role_and_cleanup
    end
    event :withdraw do
      transitions to: :withdrawn, from: [:new, :to_accept, :to_reject, :accepted, :confirmed], on_transition: :revoke_role_and_cleanup
    end
  end

  def conference
    program.conference
  end

  ##
  # Checks if the track is self-organized
  # ====Returns
  # * +true+ -> If the track has a submitter
  # * +false+ -> if the track doesn't have a submitter
  def self_organized?
    return true if submitter
    false
  end

  def to_param
    short_name
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end

  # Gives the role of the track_organizer to the submitter
  def assign_role_to_submitter
    submitter.add_role 'track_organizer', self
  end

  # Revokes the track organizer role and removes the track from events that have it set
  def revoke_role_and_cleanup
    role = Role.find_by(name: 'track_organizer', resource: self)

    if role
      role.users.each do |user|
        user.remove_role 'track_organizer', self
      end
    end

    events.each do |event|
      event.track = nil
    end
  end

  ##
  # Checks if the track is accepted
  # ====Returns
  # * +true+ -> If the track's state is 'accepted'
  # * +false+ -> If the track's state isn't 'accepted'
  def accepted?
    state == 'accepted'
  end

  ##
  # Checks if the track is confirmed
  # ====Returns
  # * +true+ -> If the track's state is 'confirmed'
  # * +false+ -> If the track's state isn't 'confirmed'
  def confirmed?
    state == 'confirmed'
  end

  ##
  # Checks if the track is accepted or confirmed
  # ====Returns
  # * +true+ -> If the track's state is 'accepted' or 'confirmed'
  # * +false+ -> If the track's state is neither 'accepted' nor 'confirmed'
  def accepted_or_confirmed?
    accepted? || confirmed?
  end

  private

  def generate_guid
    guid = SecureRandom.urlsafe_base64
#     begin
#       guid = SecureRandom.urlsafe_base64
#     end while Person.where(:guid => guid).exists?
    self.guid = guid
  end

  def capitalize_color
    self.color = color.upcase if color.present?
  end

  def conference_id
    program.conference_id
  end

  ##
  # Creates the role of the track organizer
  def create_organizer_role
    Role.where(name: 'track_organizer', resource: self).first_or_create(description: 'For the organizers of the Track')
  end

  def valid_dates
    return unless start_date && end_date

    if program && program.conference && program.conference.start_date && (start_date < program.conference.start_date)
      errors.add(:start_date, "can't be before the conference start date (#{program.conference.end_date})")
    end

    if program && program.conference && program.conference.start_date && (end_date < program.conference.start_date)
      errors.add(:end_date, "can't be before the conference start date (#{program.conference.end_date})")
    end

    if program && program.conference && program.conference.end_date && (start_date > program.conference.end_date)
      errors.add(:start_date, "can't be after the conference end date (#{program.conference.end_date})")
    end

    if program && program.conference && program.conference.end_date && (end_date > program.conference.end_date)
      errors.add(:end_date, "can't be after the conference end date (#{program.conference.end_date})")
    end

    if start_date > end_date
      errors.add(:start_date, 'can\'t be after the end_date')
    end
  end
end
