class EventSchedule < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :event
  belongs_to :room

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :schedule, presence: true
  validates :event, presence: true
  validates :room, presence: true
  validates :start_time, presence: true
  validates :event, uniqueness: { scope: :schedule }
  validate :start_after_end_hour
  validate :start_before_start_hour
  validate :same_room_as_track
  validate :during_track
  validate :valid_schedule

  scope :confirmed, -> { joins(:event).where('state = ?', 'confirmed') }
  scope :canceled, -> { joins(:event).where('state = ?', 'canceled') }
  scope :withdrawn, -> { joins(:event).where('state = ?', 'withdrawn') }

  delegate :guid, to: :room, prefix: true

  ##
  # Returns end of the event
  #
  def end_time
    start_time + event.event_type.length.minutes
  end

  ##
  # Returns event schedules that are scheduled in the same room and start_time as event
  #
  def intersecting_event_schedules
    room.event_schedules.where(start_time: start_time, schedule: schedule).where.not(id: id)
  end

  def replacement?
    event.state == 'confirmed' && (!intersecting_event_schedules.canceled.empty? || !intersecting_event_schedules.withdrawn.empty?)
  end

  private

  def start_after_end_hour
    return unless event && start_time && event.program && event.program.conference && event.program.conference.end_hour
    errors.add(:start_time, "can't be after the conference end hour (#{event.program.conference.end_hour})") if start_time.hour >= event.program.conference.end_hour
  end

  def start_before_start_hour
    return unless event && start_time && event.program && event.program.conference && event.program.conference.start_hour
    errors.add(:start_time, "can't be before the conference start hour (#{event.program.conference.start_hour})") if start_time.hour < event.program.conference.start_hour
  end

  def conference_id
    schedule.program.conference_id
  end

  ##
  # Validates that the event is scheduled in the same room as its track
  #
  def same_room_as_track
    return unless event.try(:track).try(:room)
    errors.add(:room, "must be the same as the track's room (#{event.track.room.name})") unless event.track.room == room
  end

  ##
  # Validates that the event is scheduled within its track's time slot
  #
  def during_track
    return unless event.try(:track) && start_time

    if event.track.try(:start_date) && event.track.start_date > start_time
      errors.add(:start_time, "can't be before the track's start date (#{event.track.start_date})")
    end

    if event.track.try(:end_date) && event.track.end_date + 1.day < end_time
      errors.add(:end_time, "can't be after the track's end date (#{event.track.end_date})")
    end
  end

  ##
  # Validates that the event is scheduled in its self-organized tracks's schedules
  #
  def valid_schedule
    return unless event.try(:track).try(:self_organized?) && schedule
    errors.add(:schedule, "must be one of #{event.track.name} track's schedules") unless event.track.schedules.include?(schedule)
  end
end
