class EventSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :title, :length, :scheduled_date, :language, :abstract, :speaker_ids, :type, :scheduled_room, :track

  def scheduled_date
    t = object.scheduled_start_time
    t.blank? ? '' : %( #{I18n.l t, format: :short}#{t.formatted_offset(false)} )
  end

  def speaker_ids
    speakers = object.event_users.select { |i| i.event_role == 'speaker' }
    speakers.map { |i| i.user.id }
  end

  def type
    object.event_type.try(:title)
  end

  def scheduled_room
    object.scheduled_room.try(:guid)
  end

  def track
    object.track.try(:guid)
  end

  def abstract
    # This should never happen
    if object.abstract.blank?
      nil
    else
      simple_format(object.abstract).gsub('\n', '')
    end
  end

  def length
    object.event_type.try(:length) || EventType::LENGTH_STEP
  end
end
