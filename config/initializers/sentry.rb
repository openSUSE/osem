Sentry.init do |config|
  config.allowed_environments = %|production staging|
  config.dsn = ENV['SENTRY_DSN']
end
