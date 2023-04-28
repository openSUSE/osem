# frozen_string_literal: true

def next?
  File.basename(__FILE__) == "Gemfile.next"
end

source 'https://rubygems.org'

ruby ENV.fetch('OSEM_RUBY_VERSION', '3.1.4')

# rails-assets requires >= 1.8.4
if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.8.4')
  abort "Bundler version >= 1.8.4 is required"
end

# as web framework
if next?
  gem 'rails', '~> 7.1'
else
  gem 'rails', '~> 7.0'
end

# Use Puma as the app server
gem 'puma'

# respond_to methods have been extracted to the responders gem
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#responders
gem 'responders', '~> 3.0'

# as supported databases
gem 'mysql2'
gem 'pg'

# for tracking data changes
gem 'paper_trail'

# for upload management
gem 'carrierwave'
gem 'carrierwave-bombshelter'
gem 'mini_magick'

# for internationalizing
gem 'rails-i18n'

# as authentification framework
gem 'devise'
gem 'devise_ichain_authenticatable'

# for openID authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'
gem 'omniauth-rails_csrf_protection'

# Bot-filtering
gem 'recaptcha', require: 'recaptcha/rails'

# as authorization framework
gem 'cancancan'

# for roles
gem 'rolify'

# to show flash messages from ajax requests
gem 'unobtrusive_flash', '>=3'

# as state machine
gem 'transitions', :require => %w( transitions active_record/transitions )

# for comments
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'

# as templating language
gem 'haml-rails'

# for stylesheets
gem 'sass-rails', '>= 4.0.2'

# as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# as the front-end framework
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.4.0'
gem 'cocoon'

# as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.1'

# for languages validation
gem 'iso-639'

# frontend javascripts
source 'https://rails-assets.org' do
  # for placeholder images
  gem 'rails-assets-holderjs'
  # for formating dates
  gem 'rails-assets-date.format'
  # for or parsing, validating, manipulating, and formatting dates
  gem 'rails-assets-momentjs'
  # for smooth scrolling
  gem 'rails-assets-jquery-smooth-scroll'
  # as color picker
  gem 'rails-assets-spectrum'
  # for color manipulation
  gem 'rails-assets-tinycolor'
  # for drawing triangle backgrounds
  gem 'rails-assets-trianglify'
  # for scroll way points
  gem 'rails-assets-waypoints'
  # for markdown editors
  gem 'rails-assets-bootstrap-markdown'
  # for select with icon
  gem 'rails-assets-bootstrap-select'
  gem 'rails-assets-markdown'
  gem 'rails-assets-to-markdown', '~> 3'
end

# as date picker
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'

# data tables
gem 'ajax-datatables-rails'
gem 'jquery-datatables-rails'

# for charts
gem 'chartkick'

# for displaying maps
gem 'leaflet-rails'

# for user avatars
gem 'gravtastic'

# for country selects
gem 'i18n_data'

# as PDF generator
gem 'prawn-qrcode'
gem 'prawn-rails'
# FIXME: for prawn, matrix isn't in the default set of Ruby 3.1 anymore
# see https://github.com/prawnpdf/prawn/commit/3658d5125c3b20eb11484c3b039ca6b89dc7d1b7
gem 'matrix', '~> 0.4'

# FIXME: for selenium-webdriver, rexml isn't in the default set of Ruby 3.1 anymore
# see https://github.com/SeleniumHQ/selenium/commit/526fd9d0de60a53746ffa982feab985fed09a278
gem 'rexml'

# for QR code generation
gem 'rqrcode'

# to render XLS spreadsheets
gem 'caxlsx_rails'

# as error catcher
gem 'sentry-rails'

# to make links faster
gem 'turbolinks'

# for JSON serialization of our API
gem 'active_model_serializers'

# as icon font
gem 'font-awesome-sass'

# for markdown
gem 'redcarpet'

# for recurring jobs
gem 'delayed_job_active_record'
gem 'whenever', :require => false

# to run scripts
gem 'daemons'

# to encapsulate money in objects
gem 'money-rails'

# for lists
gem 'acts_as_list'

# for switch checkboxes
gem 'bootstrap-switch-rails', '3.3.3' # Locked pending Bttstrp/bootstrap-switch#707

# for parsing OEmbed data
gem 'ruby-oembed'

# for uploading images to the cloud
gem 'cloudinary'

# for setting app configuration in the environment
gem 'dotenv-rails'

# configurable toggles for functionality
# https://github.com/mgsnova/feature
gem 'feature'

# For countable.js
gem "countable-rails"

# Both are not in a group as we use it also for rake data:demo
# for fake data
gem 'faker'
# for seeds
gem 'factory_bot_rails'

# for integrating Stripe payment gateway
gem 'stripe'

# Provides Sprockets implementation for Rails Asset Pipeline
gem 'sprockets-rails'

# for multiple speakers select on proposal/event forms
gem 'selectize-rails'

# For collecting performance data
gem 'skylight'

# memcached binary connector
gem 'dalli'

# to generate ical files
gem 'icalendar'

# to tame logs
gem 'lograge'

group :development do
  # for static code analisys
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rails', require: false
  gem 'haml_lint'
  # to open mails
  gem 'letter_opener'
  gem 'letter_opener_web'
  # as deployment system
  gem 'mina'
  # as debugger on error pages
  gem 'web-console'
end

group :test do
  # as test framework
  gem 'capybara'
  gem 'database_cleaner'
  gem 'geckodriver-helper'
  gem 'rspec-rails'
  gem 'webdrivers'
  # for measuring test coverage
  gem 'simplecov-cobertura'
  # for describing models
  gem 'shoulda-matchers', require: false
  # for stubing/mocking models
  gem 'rspec-activemodel-mocks'
  # to freeze time
  gem 'timecop'
  # for mocking external requests
  gem 'webmock'
  # for mocking Stripe responses in tests
  gem 'stripe-ruby-mock', '~> 3.1.0.rc3'
  # For validating JSON schemas
  gem 'json-schema'
  # For using 'assigns' in tests
  gem 'rails-controller-testing'
  # For managing the environment
  gem 'climate_control'
  # For PDFs
  gem 'pdf-inspector', require: "pdf/inspector"
end

group :development, :test do
  # as debugger
  gem 'byebug'
  # as development/test database
  gem 'sqlite3'
  # to test new rails version
  gem 'next_rails'
end
