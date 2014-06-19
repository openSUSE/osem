require 'coveralls'
Coveralls.wear!('rails')
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Include factory_girls syntax
  config.include FactoryGirl::Syntax::Methods

  # Enables devise sign_in function
  config.include Devise::TestHelpers, type: :controller

  # Enables devise sign_in function
  config.include Devise::TestHelpers, type: :view

  # Use capybara-webkit as default javascript driver
  Capybara.javascript_driver = :webkit

  # Includes support/login_macros for feature tests
  config.include LoginMacros, type: :feature

  # Includes omniauth macro
  config.include(OmniauthMacros)

  # Includes support/flash for feature tests
  config.include Flash, type: :feature

  config.include Sidebar, type: :view

  # As we start from scratch in April 2014, let's forbid the old :should syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

OmniAuth.config.test_mode = true
