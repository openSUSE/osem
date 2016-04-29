class ConferenceSerializer < ActiveModel::Serializer
  attributes :short_title, :title, :description, :start_date, :end_date, :picture_url,
             :difficulty_levels, :event_types, :rooms, :tracks,
             :date_range, :revision

  def difficulty_levels
    object.program.difficulty_levels.map do |difficulty_level| { id: difficulty_level.id,
                                                                 title: difficulty_level.title,
                                                                 description: difficulty_level.description
                                                               }
    end
  end

  def event_types
    object.program.event_types.map do |event_type| { id: event_type.id,
                                                     title: event_type.title,
                                                     length: event_type.length,
                                                     description: event_type.description
                                                   }
    end
  end

  def rooms
    if object.venue
      object.venue.rooms.includes(:events).map do |room| { id: room.id,
                                                           size: room.size,
                                                           events: room.events.map do |event| { guid: event.title,
                                                                                                title:  event.title,
                                                                                                subtitle: event.subtitle,
                                                                                                abstract: event.abstract,
                                                                                                description: event.description,
                                                                                                is_highlight: event.is_highlight,
                                                                                                require_registration:  event.require_registration,
                                                                                                start_time: event.start_time,
                                                                                                event_type_id: event.event_type.id,
                                                                                                difficulty_level_id: event.difficulty_level_id,
                                                                                                track_id: event.track_id,
                                                                                                speaker_names: event.speaker_names
                                                                                              }
                                                                   end
                                                         }
      end
    else
      []
    end
  end

  def tracks
    object.program.tracks.map do |track| { 'id' => track.id,
                                           'name' => track.name,
                                           'description' => track.description
                                         }
    end
  end

  def revision
    object.revision || 0
  end

  def date_range
    if defined? object.date_range_string
        object.date_range_string.try(:split, ',').try(:first)
    end
  end
end
