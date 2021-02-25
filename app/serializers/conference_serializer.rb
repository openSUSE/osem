# frozen_string_literal: true

# == Schema Information
#
# Table name: conferences
#
#  id                 :bigint           not null, primary key
#  booth_limit        :integer          default(0)
#  color              :string
#  custom_css         :text
#  custom_domain      :string
#  description        :text
#  end_date           :date             not null
#  end_hour           :integer          default(20)
#  events_per_week    :text
#  guid               :string           not null
#  logo_file_name     :string
#  picture            :string
#  registration_limit :integer          default(0)
#  revision           :integer          default(0), not null
#  short_title        :string           not null
#  start_date         :date             not null
#  start_hour         :integer          default(9)
#  ticket_layout      :integer          default("portrait")
#  timezone           :string           not null
#  title              :string           not null
#  use_vdays          :boolean          default(FALSE)
#  use_volunteers     :boolean
#  use_vpositions     :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  organization_id    :integer
#
# Indexes
#
#  index_conferences_on_organization_id  (organization_id)
#
class ConferenceSerializer < ActiveModel::Serializer
  include ApplicationHelper
  attributes :short_title, :title, :description, :start_date, :end_date, :picture_url,
             :difficulty_levels, :event_types, :rooms, :tracks,
             :date_range, :revision

  def difficulty_levels
    object.program.difficulty_levels.map do |difficulty_level| { id:          difficulty_level.id,
                                                                 title:       difficulty_level.title,
                                                                 description: difficulty_level.description
                                                               }
    end
  end

  def event_types
    object.program.event_types.map do |event_type| { id:          event_type.id,
                                                     title:       event_type.title,
                                                     length:      event_type.length,
                                                     description: event_type.description
                                                   }
    end
  end

  def rooms
    if object.venue
      object.venue.rooms.map do |room| { id:     room.id,
                                         size:   room.size,
                                         events: room.event_schedules.map do |event_schedule| { guid:                 event_schedule.event.title,
                                                                                                title:                event_schedule.event.title,
                                                                                                subtitle:             event_schedule.event.subtitle,
                                                                                                abstract:             event_schedule.event.abstract,
                                                                                                description:          event_schedule.event.description,
                                                                                                is_highlight:         event_schedule.event.is_highlight,
                                                                                                require_registration: event_schedule.event.require_registration,
                                                                                                start_time:           event_schedule.start_time,
                                                                                                event_type_id:        event_schedule.event.event_type.id,
                                                                                                difficulty_level_id:  event_schedule.event.difficulty_level_id,
                                                                                                track_id:             event_schedule.event.track_id,
                                                                                                speaker_names:        event_schedule.event.speaker_names
                                                                                              }
                                                 end
                                       }
      end
    else
      []
    end
  end

  def tracks
    object.program.tracks.map do |track| { 'id'          => track.id,
                                           'name'        => track.name,
                                           'description' => track.description
                                         }
    end
  end

  def revision
    object.revision || 0
  end

  def date_range
    if defined? date_string(object.start_date, object.end_date)
      date_string(object.start_date, object.end_date).try(:split, ',').try(:first)
    end
  end
end
