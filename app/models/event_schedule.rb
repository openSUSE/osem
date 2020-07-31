# frozen_string_literal: true

class EventSchedule < ApplicationRecord
  default_scope { where(enabled: true) }
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

  scope :with_event_states, ->(*states){ joins(:event).where('events.state IN (?)', states) }

  delegate :guid, to: :room, prefix: true

  def timezone
    event.conference.timezone
  end

  ##
  # True within `threshold` before and after the event.
  #
  def happening_now?(threshold = 30.minutes)
    in_tz_start = start_time.in_time_zone(timezone)
    in_tz_end = end_time.in_time_zone(timezone)
    in_tz_start -= in_tz_start.utc_offset
    in_tz_end -= in_tz_end.utc_offset
    begin_range = Time.now - threshold
    end_range = Time.now + threshold
    event_time_range = in_tz_start..in_tz_end
    now_range = begin_range..end_range
    # TODO: There's probably better logic.
    event_time_range.overlaps?(now_range) && (in_tz_end > Time.now)
  end

  def self.withdrawn_or_canceled_event_schedules(schedule_ids)
    EventSchedule
      .unscoped
      .where(schedule_id: schedule_ids)
      .with_event_states(:withdrawn, :canceled)
  end

  ##
  # Returns end of the event
  #
  def end_time
    start_time + event.event_type.length.minutes
  end

  ##
  # Returns a time + room number string for sorting.
  #
  def sortable_timestamp
    "#{start_time.to_i}-#{room&.order}"
  end

  ##
  # Returns event schedules that are scheduled in the same room and start_time as event
  #
  def intersecting_event_schedules
    EventSchedule
      .unscoped
      .where(room_id: room_id, start_time: start_time, schedule_id: schedule_id)
      .where.not(id: id)
  end

  # event_schedule_source is a cached enumerable object that helps
  # avoid repetitive EXISTS queries when rendering the schedule carousel partial
  def replacement?(event_schedule_source = nil)
    return false unless event.state == 'confirmed'
    return replaced_event_schedules.exists? unless event_schedule_source

    event_schedule_source.any? { |event_schedule| intersects_with?(event_schedule) }
  end

  # the event schedule that `self` replaced
  def replaced_event_schedule
    replaced_event_schedules.first
  end

  # NOTE: This and `intersecting_event_schedules` share the flaw that they do not
  # detect overlapping schedules where the start times are different (i.e., where
  # only a portion of the time intersects).
  def intersects_with?(other)
    other != self &&
      other.room_id == room_id &&
      other.start_time == start_time &&
      other.schedule_id == schedule_id
  end

  private

  def replaced_event_schedules
    intersecting_event_schedules.with_event_states(:withdrawn, :canceled)
  end

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
