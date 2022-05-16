RSpec.configure do |config|
  # Tracker deprecation messages in each file
  if ENV.fetch('DEPRECATION_TRACKER', nil)
    DeprecationTracker.track_rspec(
      config,
      shitlist_path:     'spec/support/deprecation_shitlist.json',
      mode:              ENV.fetch('DEPRECATION_TRACKER'),
      transform_message: ->(message) { message.gsub("#{Rails.root}/", '') }
    )
  end
end
