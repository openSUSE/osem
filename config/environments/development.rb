Osem::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Use letter_opener_web for Vagrant (launchy won't work)
  config.action_mailer.delivery_method = ENV['USER'] == 'vagrant' ? :letter_opener_web : :letter_opener

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Set the detault url for action mailer
  config.action_mailer.default_url_options = { host: (ENV['OSEM_HOSTNAME'] || 'localhost:3000') }

  # Set the secret key base if it's not set via other means
  config.secret_key_base ||= 'f4be765bc98e516de82ac01daa8f8aa11c5ca13cb6c911887851ac89457b6c0b056b2361a21b5c08926c9386e0f91eef84fc0b103d522bf00bc0c78ea8ce7c58'

  # Use omniauth mock credentials
  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
                              provider: 'facebook',
                              uid: 'facebook-test-uid-1',
                              info: {
                                name: 'admin admin',
                                email: 'admin@email.com',
                                username: 'admin_admin'
                              },
                              credentials: {
                                token: 'fb_mock_token',
                                secret: 'fb_mock_secret'
                              }
                            )

  OmniAuth.config.mock_auth[:google] =
      OmniAuth::AuthHash.new(
                              provider: 'google',
                              uid: 'google-test-uid-1',
                              info: {
                                name: 'simple user',
                                email: 'user0@email.com',
                                username: 'simple_user0'
                              },
                              credentials: {
                                token: 'google_mock_token',
                                secret: 'google_mock_secret'
                              }
                            )

  OmniAuth.config.mock_auth[:suse] =
      OmniAuth::AuthHash.new(
                              provider: 'suse',
                              uid: 'suse-test-uid-1',
                              info: {
                                name: 'another user',
                                email: 'user1@email.com',
                                username: 'another_user'
                              },
                              credentials: {
                                token: 'suse_mock_token',
                                secret: 'suse_mock_secret'
                              }
                            )


  config.after_initialize do
    Devise.setup do |devise_config|
      # Enable ichain test mode
      devise_config.ichain_test_mode = true
    end
  end

  #Initialize Payment Gateway with valid credentials
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::StripeGateway.new(:login => ENV['OSEM_GATEWAY_TEST_SECRET_KEY'])
end



