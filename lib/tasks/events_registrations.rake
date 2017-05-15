namespace :events_registrations do
  desc 'Sets max_attendees to 1 or number of registrations, if require_registration is set'
  task set_max_attendees: :environment do
    @events = Event.all.where(require_registration: true, max_attendees: nil)
    puts "Fixing max_attendees attribute for #{@events.length} events."
    puts "The IDs of those events are: #{@events.pluck(:id)}"

    @events.each do |event|
      if event.registrations.any?
        event.max_attendees = event.registrations.count
      else
        event.max_attendees = 1
      end
      event.save!
    end

    puts "All done!"
  end

  desc "Deletes dupicate entries"
  task deduplicate: :environment do
    if ActiveRecord::Migrator.get_all_versions.include? 20160403214841
      duplicates = EventsRegistration.all.map { |er| er.id if er.valid? == false}.compact

      puts "Duplicates found: #{duplicates.count}"
      if duplicates.count > 0
        puts "With IDs: #{duplicates}"
      end

      EventsRegistration.all.each do |er|
        records = EventsRegistration.where(registration_id: er.registration_id, event_id: er.event_id)
        if records.count > 1
          # Iterate through duplicates (excluding 1st record)
          (1..(records.count - 1)).each do |i|
            puts "Deleting EventsRegistration record with ID #{records[i].id} ..."
            if records[i].destroy
              puts 'Succeeded!'
            else
              puts 'Failed!'
            end
          end
        end
      end
    else
      puts 'Please migrate to run this task. Make sure your migration include 20160403214841'
    end
  end
end
