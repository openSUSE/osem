CarrierWave.configure do |config|
  config.storage = :file
  config.cache_storage = :file
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  config.enable_processing = false if Rails.env.test?
end
