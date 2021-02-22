# frozen_string_literal: true

# == Schema Information
#
# Table name: event_schedules
#
#  id          :bigint           not null, primary key
#  enabled     :boolean          default(TRUE)
#  start_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer
#  room_id     :integer
#  schedule_id :integer
#
# Indexes
#
#  index_event_schedules_on_event_id                  (event_id)
#  index_event_schedules_on_event_id_and_schedule_id  (event_id,schedule_id) UNIQUE
#  index_event_schedules_on_room_id                   (room_id)
#  index_event_schedules_on_schedule_id               (schedule_id)
#
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
