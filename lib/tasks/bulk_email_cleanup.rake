# frozen_string_literal: true

namespace :bulk_email do
  desc 'Clean up expired bulk email sessions'
  task cleanup: :environment do
    count = BulkEmailSession.cleanup_expired!
    puts "Cleaned up #{count} expired bulk email sessions"
  end
end