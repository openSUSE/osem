# frozen_string_literal: true

namespace :data do
  desc 'Nullify wrong foreign keys'

  task nullify_nonexistent_foreign_keys: :environment do
    # Track
    events_track = Event.all.select { |e| e.track_id && Track.find_by(id: e.track_id).nil? }
    nullify_attribute(events_track, 'track_id')

    # Difficulty level
    events_difficulty_level = Event.all.select { |e| e.difficulty_level_id && DifficultyLevel.find_by(id: e.difficulty_level_id).nil? }
    nullify_attribute(events_difficulty_level, 'difficulty_level_id')

    # Room
    events_room = Event.all.select { |e| e.room_id && Room.find_by(id: e.room_id).nil? }
    nullify_attribute(events_room, 'room_id')
  end

  desc 'Drop all ahoy events'
  task drop_all_ahoy_events: :environment do
    class TmpAhoy < ActiveRecord::Base
      self.table_name = 'ahoy_events'
    end
    TmpAhoy.delete_all
  end

  def nullify_attribute(collection, attribute)
    puts "Will nullify #{attribute} in #{ActionController::Base.helpers.pluralize(collection.length, 'event')}."
    if collection.any?
      puts "IDs: #{collection.map(&:id)}"
      collection.each do |item|
        item.send(attribute+'=', nil)
        item.save!
      end
      puts "Fixed #{attribute}!"
    end
  end
end
