# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'

if ENV['TRAVIS']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  Coveralls.wear!('rails')
else
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'
require 'shoulda/matchers'
# To avoid confusion on missed migrations - use Rails 4 checker to ensure
# all migrations applied
ActiveRecord::Migration.maintain_test_schema!

# Add poltergeist to use it as JS driver
require 'capybara/poltergeist'
require 'phantomjs'

# Adds rspec helper provided by paper_trail
# makes it easier to control when PaperTrail is enabled during testing.
require 'paper_trail/frameworks/rspec'

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

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      Rails.application.load_seed
      example.run
    end
  end

  # poltergeist as a underlying mech for Capybara
  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs: Phantomjs.path, js_errors: false)
  end

  # Includes helpers and connect them to specific types of tests
  config.include FactoryGirl::Syntax::Methods
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
end

OmniAuth.config.test_mode = true
