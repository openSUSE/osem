# frozen_string_literal: true

namespace :data do
  desc 'Sets conference_id in all pre-existing PaperTrail::Version objects'
  task set_conference_in_versions: :environment do
    ids_with_failure = []
    PaperTrail::Version.where(conference_id: nil, item_type: %w[Conference Event]).each do |version|
      # All pre-existing versions are either of Conference or Event
      if version.item_type == 'Conference'
        version.update_attributes(conference_id: version.item_id)

      elsif version.item_type == 'Event'
        event = version.item
        unless event || Event.find_by(id: version.item_id)
          puts 'Not updating versions of deleted event...'
          next
        end
        event ||= (version.reify || version.next.reify)
        conference_id = if event.try(:program)
                          event.program.conference_id
                        # Event had attribute conference_id before it was replaced with program_id
                        elsif version.changeset[:conference_id]
                          version.changeset[:conference_id].second
                        elsif version.changeset[:program_id]
                          version.changeset[:program_id].second
                        elsif version.object && (object = YAML.safe_load(version.object))
                          object['conference_id']
                        else
                          ids_with_failure << version.id
                          puts "Setting conference_id value failed for PaperTrail::Version object with ID=#{version.id}"
                          nil
                        end
        version.update_attributes(conference_id: conference_id)
      end
    end
    puts 'All done!'
    puts "IDs with failures: #{ids_with_failure}" if ids_with_failure.any?
  end
end
