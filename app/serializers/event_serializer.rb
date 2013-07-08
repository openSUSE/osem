class EventSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :title, :length, :date, :language, :abstract,
    :speaker_ids, :type, :room, :track

  def date
    object.start_time
  end

  def speaker_ids
    speakers = object.event_people.select {|i| i.event_role == "speaker" }
    speakers.map {|i| i.person.guid}
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

  def abstract
    # This should never happen
    if object.abstract.blank?
      nil
    else
      simple_format(object.abstract).gsub("\n", "")
    end
  end

  # FIXME: duplicated logic from Event#as_json
  def length
    object.event_type.try(:length) || 25
  end
end
