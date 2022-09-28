# frozen_string_literal: true

class EventScheduleSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attribute :start_time, key: :date
  attributes :room

  def room
    object.room.guid
  end
end
