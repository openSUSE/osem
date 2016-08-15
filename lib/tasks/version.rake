namespace :data do
  desc 'Sets conference_id in all pre-existing PaperTrail::Version objects'
  task set_conference_in_versions: :environment do

    PaperTrail::Version.where(conference_id: nil, item_type: ['Conference', 'Event']).each do |version|
      # All pre-existing versions are either of Conference or Event
      if version.item_type == 'Conference'
        version.update_attributes(conference_id: version.item_id)

      elsif version.item_type == 'Event'
        event = (version.item || version.reify || version.next.reify)
        if event.try(:program)
          version.update_attributes(conference_id: event.program.conference_id)
        else
          puts "Setting conference_id value failed for PaperTrail::Version object with ID=#{version.id}"
        end
      end
    end
    puts 'All done!'
  end
end
