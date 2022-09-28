# frozen_string_literal: true

class EventSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :title, :length, :scheduled_date, :language, :abstract, :speaker_ids, :type, :room, :track

  def scheduled_date
    object.time&.change(zone: object.program.conference.timezone)
  end

  def speaker_ids
    speakers = object.event_users.select { |i| i.event_role == 'speaker' }
    speakers.map { |i| i.user.id }
  end

  def type
    object.event_type.try(:title)
  end

  def room
    object.room.try(:guid)
  end

  def track
    object.track.try(:guid)
  end

  def length
    object.event_type.try(:length) || object.event_type.program.schedule_interval
  end
end
