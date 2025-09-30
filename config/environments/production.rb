require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Set the secret_key_base from the env, if not set by any other means
  config.secret_key_base ||= ENV.fetch('SECRET_KEY_BASE', nil)

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true if ENV['FORCE_SSL'].present?

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

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

  # Provide a default host for URLs
  Rails.application.routes.default_url_options[:host] = ENV.fetch('OSEM_HOSTNAME', 'localhost:3000')
  config.action_controller.default_url_options = Rails.application.routes.default_url_options
  config.action_mailer.default_url_options = Rails.application.routes.default_url_options

  # Configure outgoing mail
  config.action_mailer.smtp_settings = {
    address:              ENV.fetch('OSEM_SMTP_ADDRESS', 'localhost'),
    port:                 ENV.fetch('OSEM_SMTP_PORT', '25').to_i,
    user_name:            ENV.fetch('OSEM_SMTP_USERNAME', nil),
    password:             ENV.fetch('OSEM_SMTP_PASSWORD', nil),
    authentication:       ENV.fetch('OSEM_SMTP_AUTHENTICATION', nil)&.to_sym,
    domain:               ENV.fetch('OSEM_SMTP_DOMAIN', nil),
    enable_starttls_auto: ENV.fetch('OSEM_SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true',
    openssl_verify_mode:  ENV.fetch('OSEM_SMTP_OPENSSL_VERIFY_MODE', nil)&.to_sym
  }.compact

  # Use memcache cluster as cache store in production
  if ENV["OSEM_MEMCACHED_SERVERS"]
    config.cache_store = :mem_cache_store, ENV['OSEM_MEMCACHED_SERVERS'].split(','), {
      username: ENV.fetch('OSEM_MEMCACHED_USERNAME', nil),
      password: ENV.fetch('OSEM_MEMCACHED_PASSWORD', nil)
    }
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
