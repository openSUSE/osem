namespace :events do
  desc 'Nullifies wrong foreign keys for Track, Room, DifficultyLevel'

  task fix_wrong_track: :environment do
    events = Event.all.select { |e| e.track_id && Track.find_by(id: e.track_id).nil? }
    puts "Will remove track_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.track_id = nil
        event.save!
      end
      puts 'All done!'
    end
  end

  task fix_wrong_difficulty_level: :environment do
    events = Event.all.select { |e| e.difficulty_level_id && DifficultyLevel.find_by(id: e.difficulty_level_id).nil? }
    puts "Will remove difficulty_level_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.difficulty_level_id = nil
        event.save!
      end
      puts 'All done!'
    end
  end

  task fix_wrong_room: :environment do
    events = Event.all.select { |e| e.room_id && Room.find_by(id: e.room_id).nil? }
    puts "Will remove track_id from #{ActionController::Base.helpers.pluralize(events.length, 'event')}."

    if events.any?
      puts "Event IDs: #{events.map(&:id)}"
      events.each do |event|
        event.room_id = nil
        event.save!
      end
      puts 'All done!'
    end
  end
end
