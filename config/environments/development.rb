Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Set the detault url for action mailer
  config.action_mailer.default_url_options = { host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000') }

  # Use omniauth mock credentials
  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
                              provider:    'facebook',
                              uid:         'facebook-test-uid-1',
                              info:        {
                                name:     'facebook user',
                                email:    'user-facebook@example.com',
                                username: 'user_facebook'
                              },
                              credentials: {
                                token:  'fb_mock_token',
                                secret: 'fb_mock_secret'
                              }
                            )

  OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider:    'google',
                              uid:         'google-test-uid-1',
                              info:        {
                                name:     'google user',
                                email:    'user-google@example.com',
                                username: 'user_google'
                              },
                              credentials: {
                                token:  'google_mock_token',
                                secret: 'google_mock_secret'
                              }
                            )

  OmniAuth.config.mock_auth[:suse] =
      OmniAuth::AuthHash.new(
                              provider:    'suse',
                              uid:         'suse-test-uid-1',
                              info:        {
                                name:     'suse user',
                                email:    'user-suse@example.com',
                                username: 'user_suse'
                              },
                              credentials: {
                                token:  'suse_mock_token',
                                secret: 'suse_mock_secret'
                              }
                            )

  OmniAuth.config.mock_auth[:github] =
      OmniAuth::AuthHash.new(
                              provider:    'github',
                              uid:         'github-test-uid-1',
                              info:        {
                                name:     'github user',
                                email:    'user-github@example.com',
                                username: 'user_github'
                              },
                              credentials: {
                                token:  'github_mock_token',
                                secret: 'github_mock_secret'
                              }
                            )

  config.after_initialize do
    Devise.setup do |devise_config|
      # Enable ichain test mode
      devise_config.ichain_test_mode = true
    end
  end
end
