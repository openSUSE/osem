# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
Rails.application.config.time_zone = (ENV['OSEM_TIME_ZONE'] || 'UTC')
