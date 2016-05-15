namespace :events do
  desc 'Create demo data using our factories'
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
end
