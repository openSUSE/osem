RSpec.configure do |config|
  # Tracker deprecation messages in each file
  if ENV['DEPRECATION_TRACKER']
    DeprecationTracker.track_rspec(
      config,
      shitlist_path:     'spec/support/deprecation_shitlist.json',
      mode:              ENV['DEPRECATION_TRACKER'],
      transform_message: ->(message) { message.gsub("#{Rails.root}/", '') }
    )
  end
end
