require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true if ENV['FORCE_SSL'].present?

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Enable lograge
  config.lograge.enabled = true
  config.lograge.custom_payload do |controller|
    # exceptions = ['controller', 'action', 'format', 'id']
    {
      # params: event.payload[:params].except(*exceptions),
      user: controller.current_user.try(:username)
    }
  end
  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id _method authenticity_token]
    {
      params: event.payload[:params].except(*exceptions)
    }
  end

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = Rails.application.routes.default_url_options

  # Specify outgoing SMTP server.
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch('OSEM_SMTP_ADDRESS', 'localhost'),
    port:                 ENV.fetch('OSEM_SMTP_PORT', 25),
    user_name:            ENV.fetch('OSEM_SMTP_USERNAME', nil),
    password:             ENV.fetch('OSEM_SMTP_PASSWORD', nil),
    authentication:       ENV.fetch('OSEM_SMTP_AUTHENTICATION', 'plain').try(:to_sym),
    domain:               ENV.fetch('OSEM_SMTP_DOMAIN', nil),
    enable_starttls_auto: ENV.fetch('OSEM_SMTP_ENABLE_STARTTLS_AUTO', nil),
    openssl_verify_mode:  ENV.fetch('OSEM_SMTP_OPENSSL_VERIFY_MODE', nil)
  }.compact

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Use memcache cluster as cache store in production
  if ENV["OSEM_MEMCACHED_SERVERS"]
    config.cache_store = :mem_cache_store, ENV['OSEM_MEMCACHED_SERVERS'].split(','), {
      username: ENV.fetch('OSEM_MEMCACHED_USERNAME', nil),
      password: ENV.fetch('OSEM_MEMCACHED_PASSWORD', nil)
    }
  end
end
