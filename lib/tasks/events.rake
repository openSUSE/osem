namespace :data do
  desc 'Nullifies wrong foreign keys for Track, Room, DifficultyLevel'

  task fix_wrong_foreign_keys: :environment do
    # Tracks
    events = Event.all.select { |e| e.track_id && Track.find_by(id: e.track_id).nil? }
    puts "Will remove track_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.track_id = nil
        event.save!
      end
      puts 'Fixed track_id!'
    end

    # Difficulty levels
    events = Event.all.select { |e| e.difficulty_level_id && DifficultyLevel.find_by(id: e.difficulty_level_id).nil? }
    puts "Will remove difficulty_level_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.difficulty_level_id = nil
        event.save!
      end
      puts 'Fixed difficulty_level_id!'
    end

    #Rooms
    events = Event.all.select { |e| e.room_id && Room.find_by(id: e.room_id).nil? }
    puts "Will remove track_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.room_id = nil
        event.save!
      end
      puts 'Fixed room_id!'
    end
  end
end
