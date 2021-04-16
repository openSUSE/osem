Osem::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.public_file_server.enabled = false
  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  config.assets.css_compressor = :sass
  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.assets.gzip = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = !!ENV['FORCE_SSL']

  # See everything in the log (default is :info)
  config.log_level = ENV['OSEM_LOG_LEVEL'].try(:to_sym) || :info

  # Prepend all log lines with the following tags
  config.log_tags = [:uuid]

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  if ENV["OSEM_MEMCACHED_SERVERS"]
    config.cache_store = :mem_cache_store, ENV["OSEM_MEMCACHED_SERVERS"].split(','), {
      username: ENV["OSEM_MEMCACHED_USERNAME"],
      password: ENV["OSEM_MEMCACHED_PASSWORD"]
    }
  end

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Set the detault url for action mailer
  config.action_mailer.default_url_options = { host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000') }

  # Set the smtp configuration of your service provider
  # For further details of each configuration checkout: http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration
  config.action_mailer.smtp_settings = {
    address:              ENV['OSEM_SMTP_ADDRESS'],
    port:                 ENV['OSEM_SMTP_PORT'],
    user_name:            ENV['OSEM_SMTP_USERNAME'],
    password:             ENV['OSEM_SMTP_PASSWORD'],
    authentication:       ENV['OSEM_SMTP_AUTHENTICATION'].try(:to_sym),
    domain:               ENV['OSEM_SMTP_DOMAIN'],
    enable_starttls_auto: ENV['OSEM_SMTP_ENABLE_STARTTLS_AUTO'],
    openssl_verify_mode:  ENV['OSEM_SMTP_OPENSSL_VERIFY_MODE']
  }.compact

  # Set the secret_key_base from the env, if not set by any other means
  config.secret_key_base ||= ENV["SECRET_KEY_BASE"]

  # Mailbot settings
  config.mailbot = {
    ytlf_ticket_id: (ENV['YTLF_TICKET_ID'] || 50),
    bcc_address:    ENV['OSEM_MESSAGE_BCC_ADDRESS']
  }
end
