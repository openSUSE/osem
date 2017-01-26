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

  validate :not_overlapping

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
  # Returns events that are scheduled in the same room and start_time as event
  #
  def intersecting_events
    room.event_schedules.where(start_time: start_time, schedule: schedule).where.not(id: id)
  end

  private

  def conference_id
    schedule.program.conference_id
  end

  def not_overlapping
    if room
      room.event_schedules.where(schedule: schedule).where.not(id: id).each do |e|
        if (e.start_time <= start_time && e.end_time > start_time) || (e.end_time >= end_time && e.start_time < end_time) || (e.start_time > start_time && e.start_time < end_time)
          errors.add(:event, "can't be scheduled at the same time than other event in the same room")
          break
        end
      end
    end
  end
end
