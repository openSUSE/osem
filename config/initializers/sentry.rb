Sentry.init do |config|
  config.enabled_environments = %|production staging|
  config.dsn = ENV['SENTRY_DSN']
end
