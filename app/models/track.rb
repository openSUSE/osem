# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id                   :bigint           not null, primary key
#  cfp_active           :boolean          not null
#  color                :string
#  description          :text
#  end_date             :date
#  guid                 :string           not null
#  name                 :string           not null
#  relevance            :text
#  short_name           :string           not null
#  start_date           :date
#  state                :string           default("new"), not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#  room_id              :integer
#  selected_schedule_id :integer
#  submitter_id         :integer
#
# Indexes
#
#  index_tracks_on_room_id               (room_id)
#  index_tracks_on_selected_schedule_id  (selected_schedule_id)
#  index_tracks_on_submitter_id          (submitter_id)
#
class Track < ApplicationRecord
  include ActiveRecord::Transitions
  include RevisionCount

  resourcify :roles, dependent: :delete_all

  belongs_to :program, touch: true
  belongs_to :submitter, class_name: 'User'
  belongs_to :room
  belongs_to :selected_schedule, class_name: 'Schedule'
  has_many :events, dependent: :nullify
  has_many :schedules

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  before_create :generate_guid
  validates :name, presence: true
  validates :color, format: /\A#[0-9A-F]{6}\z/
  validates :short_name,
            presence:   true,
            format:     /\A[a-zA-Z0-9_-]*\z/,
            uniqueness: {
              scope: :program
            }
  validates :state,
            presence:  true,
            inclusion: { in: %w(new to_accept accepted confirmed to_reject rejected canceled withdrawn) }
  validates :cfp_active, inclusion: { in: [true, false] }
  validates :start_date, presence: true, if: :self_organized_and_accepted_or_confirmed?
  validates :end_date, presence: true, if: :self_organized_and_accepted_or_confirmed?
  validates :room, presence: true, if: :self_organized_and_accepted_or_confirmed?
  validates :relevance, presence: true, if: :self_organized?
  validates :description, presence: true, if: :self_organized?
  validate :dates_within_conference_dates
  validate :start_date_before_end_date
  validate :valid_room
  validate :overlapping

  before_validation :capitalize_color

  scope :accepted, -> { where(state: 'accepted') }
  scope :confirmed, -> { where(state: 'confirmed') }
  scope :cfp_active, -> { where(cfp_active: true) }
  scope :self_organized, -> { where.not(submitter: nil) }

  state_machine initial: :new do
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
    event :to_accept do
      transitions to: :to_accept, from: [:new, :to_reject]
    end
    event :accept do
      transitions to: :accepted, from: [:new, :to_accept], on_transition: :create_organizer_role
    end
    event :confirm do
      transitions to: :confirmed, from: [:accepted], on_transition: :assign_role_to_submitter
    end
    event :to_reject do
      transitions to: :to_reject, from: [:new, :to_accept]
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

  ##
  # Revokes the track organizer role, destroys the track's schedule, removes the
  # track from events that have it set and reverts their state to new
  #
  def revoke_role_and_cleanup
    role = Role.find_by(name: 'track_organizer', resource: self)

    role&.users&.each do |user|
      user.remove_role 'track_organizer', self
    end

    self.selected_schedule_id = nil
    save!

    schedules.each(&:destroy!)

    events.each do |event|
      event.track = nil
      event.state = 'new'
      event.save!
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
  # Checks if a self-organized track is accepted or confirmed
  # ====Returns
  # * +true+ -> If the track's state is 'accepted' or 'confirmed'
  # * +false+ -> If the track's state is neither 'accepted' nor 'confirmed'
  def self_organized_and_accepted_or_confirmed?
    self_organized? && (accepted? || confirmed?)
  end

  def update_state(transition)
    error = ''

    begin
      send(transition)
    rescue Transitions::InvalidTransition => e
      error += "State update failed. #{e.message} "
    end

    error += errors.full_messages.join(', ') unless save
    error
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

  ##
  # Verify that the track's dates are between the conference's dates
  #
  def dates_within_conference_dates
    return unless start_date && end_date && program.try(:conference).try(:start_date) && program.try(:conference).try(:end_date)

    errors.add(:start_date, "can't be outside of the conference's dates (#{program.conference.start_date}-#{program.conference.end_date})") unless (program.conference.start_date..program.conference.end_date).cover?(start_date)
    errors.add(:end_date, "can't be outside of the conference's dates (#{program.conference.start_date}-#{program.conference.end_date})") unless (program.conference.start_date..program.conference.end_date).cover?(end_date)
  end

  ##
  # Verify that the start date isn't after the end date
  #
  def start_date_before_end_date
    return unless start_date && end_date

    errors.add(:start_date, 'can\'t be after the end date') if start_date > end_date
  end

  ##
  # Verify that the room is a room of the conference
  #
  def valid_room
    return unless room.try(:venue).try(:conference) && program.try(:conference)

    errors.add(:room, "must be a room of #{program.conference.venue.name}") unless room.venue.conference == program.conference
  end

  ##
  # Check that there is no other track in the same room with overlapping dates
  #
  def overlapping
    return unless start_date && end_date && room && program.try(:tracks)

    (program.tracks.accepted + program.tracks.confirmed - [self]).each do |existing_track|
      next unless existing_track.room == room && existing_track.start_date && existing_track.end_date

      if start_date >= existing_track.start_date && start_date <= existing_track.end_date ||
         end_date >= existing_track.start_date && end_date <= existing_track.end_date ||
         start_date <= existing_track.start_date && end_date >= existing_track.end_date
        errors.add(:track, 'has overlapping dates with a confirmed or accepted track in the same room')
        break
      end
    end
  end
end
