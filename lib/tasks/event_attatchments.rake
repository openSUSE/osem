# frozen_string_literal: true

namespace :db do
  desc 'Destroy event_attachments versions'

  task destroy_event_attachment_versions: :environment do
    PaperTrail::Version.where(item_type: 'EventAttachment').try(:destroy_all)
    puts 'Version records with event_attachment have been destroyed'
  end
end