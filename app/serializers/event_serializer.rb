# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                           :bigint           not null, primary key
#  abstract                     :text
#  comments_count               :integer          default(0), not null
#  committee_review             :text
#  description                  :text
#  guid                         :string           not null
#  is_highlight                 :boolean          default(FALSE)
#  language                     :string
#  max_attendees                :integer
#  progress                     :string           default("new"), not null
#  proposal_additional_speakers :text
#  public                       :boolean          default(TRUE)
#  require_registration         :boolean
#  start_time                   :datetime
#  state                        :string           default("new"), not null
#  submission_text              :text
#  subtitle                     :string
#  title                        :string           not null
#  week                         :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  difficulty_level_id          :integer
#  event_type_id                :integer
#  program_id                   :integer
#  room_id                      :integer
#  track_id                     :integer
#
class EventSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  attributes :guid, :title, :length, :scheduled_date, :language, :abstract, :speaker_ids, :type, :room, :track

  def scheduled_date
    t = object.time
    t.blank? ? '' : %( #{I18n.l t, format: :short}#{t.formatted_offset(false)} )
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
