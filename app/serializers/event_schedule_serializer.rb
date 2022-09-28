# frozen_string_literal: true

class EventScheduleSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :date, :room

  def date
    object.start_time&.change(zone: object.event.program.conference.timezone)
  end

  def room
    object.room.guid
  end
end
