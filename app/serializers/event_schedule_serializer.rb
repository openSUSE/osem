class EventScheduleSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :date, :room

  def date
    t = object.start_time
    t.blank? ? '' : %( #{I18n.l t, format: :short}#{t.formatted_offset(false)} )
  end

  def room
    object.room.guid
  end
end
