Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  config.active_support.test_order = :sorted

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test


  # Do not perform deliveries on test
  config.action_mailer.perform_deliveries = false

  # Set the detault url for action mailer
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Set the secret key base if it's not set via other means
  config.secret_key_base ||= 'f4be765bc98e516de82ac01daa8f8aa11c5ca13cb6c911887851ac89457b6c0b056b2361a21b5c08926c9386e0f91eef84fc0b103d522bf00bc0c78ea8ce7c58'

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.after_initialize do
    ActiveRecord::Base.logger = nil
    # Set Time.now to May 1, 2014 00:01:00 AM (at this instant), but allow it to move forward
    t = Time.local(2014, 05, 01, 00, 01, 00)
    Timecop.travel(t)
    ActiveSupport::Deprecation.silenced = true
  end


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
