# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'

if ENV['TRAVIS']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'shoulda/matchers'
require 'webdrivers'

# To avoid confusion on missed migrations - use Rails 4 checker to ensure
# all migrations applied
ActiveRecord::Migration.maintain_test_schema!

# Adds rspec helper provided by paper_trail
# makes it easier to control when PaperTrail is enabled during testing.
require 'paper_trail/frameworks/rspec'

# Make htmlescape() available
require 'erb'
include ERB::Util

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

  # Test within database transactions
  config.use_transactional_examples = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  Capybara.disable_animation = true

  Capybara.register_driver :firefox do |app|
    Capybara::Selenium::Driver.new(app, browser: :firefox)
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :firefox_headless do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.args << '--headless'
    options.args << '--window-size=1920,1080'
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end

  Capybara.register_driver :chrome_headless do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.args << '--window-size=1920x1080'
    options.args << '--headless'
    options.args << '--no-sandbox'
    options.args << '--disable-gpu'
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.default_max_wait_time = 10 # seconds

  # use a real browser for JS tests
  Capybara.javascript_driver = (
    ENV['OSEM_TEST_DRIVER'].try(:to_sym) || :chrome_headless
  )

  # Includes helpers and connect them to specific types of tests
  config.include FactoryBot::Syntax::Methods
  config.include OmniauthMacros
  config.include Devise::TestHelpers, type: :controller
  config.include LoginMacros, type: :feature
  config.include Flash, type: :feature
  config.include Sidebar, type: :view
  config.include Devise::TestHelpers, type: :view

  # As we start from scratch in April 2014, let's forbid the old :should syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reuse rspec as mocking framework
  config.mock_framework = :rspec

  # Types of tests (controller, feature, model) will
  # be inferred from subfolder name
  config.infer_spec_type_from_file_location!

  # Enable this if you like to see what you're debugging
  # config.after(:example) do |example|
  #   if example.exception
  #     save_and_open_screenshot
  #     save_and_open_page
  #   end
  # end

  # use the config to use
  # t('some.locale.key') instead of always having to type I18n.t
  config.include AbstractController::Translation
end

OmniAuth.config.test_mode = true

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
