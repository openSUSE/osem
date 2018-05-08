source 'https://rubygems.org'

# rails-assets requires >= 1.8.4
if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.8.4')
  abort "Bundler version >= 1.8.4 is required"
end

# as web framework
gem 'rails', '~> 5.0.5'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# enables serving assets in production and setting your logger to standard out
# both of which are required to run an application on a twelve-factor provider
# like heroku.com
gem 'rails_12factor', group: :production

# respond_to methods have been extracted to the responders gem
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#responders
gem 'responders', '~> 2.0'

# as the database for Active Record
# choose only one
gem 'mysql2'
# gem 'pg'

# for tracking data changes
gem 'paper_trail'

# for upload management
gem 'carrierwave'
gem 'carrierwave-bombshelter'
gem 'mini_magick'

# for internationalizing
gem 'rails-i18n', '~> 5.0.0'

# as authentification framework
gem 'devise'
gem 'devise_ichain_authenticatable'

# for openID authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'

# Bot-filtering
gem 'recaptcha', require: 'recaptcha/rails'

# as authorization framework
gem 'cancancan', '~> 2.0'

# for roles
gem 'rolify'

# to show flash messages from ajax requests
gem 'unobtrusive_flash', '>=3'

# as state machine
gem 'transitions', :require => %w( transitions active_record/transitions )

# for comments
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set', '~> 3.1.3'

# as templating language
gem 'haml-rails'

# for stylesheets
gem 'sass-rails', '>= 4.0.2'

# as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# as the front-end framework
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.3.4.1'
gem 'cocoon'
gem 'formtastic', '~> 3.1.5'
gem 'formtastic-bootstrap'

# as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'

# for languages validation
gem 'iso-639'

gem 'thor', '~> 0.19'

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
  gem 'rails-assets-markdown'
  gem 'rails-assets-to-markdown'
end

# as date picker
gem 'bootstrap3-datetimepicker-rails', '~> 3.0.2'
gem 'jquery-datatables-rails', '~> 2.2.1'

# for charts
gem 'chart-js-rails'

# for displaying maps
gem 'leaflet-rails'

# for user avatars
gem 'gravtastic'

# for country selects
gem 'country_select'

# as PDF generator
gem 'prawn-qrcode', '~> 0.2.2.1'
gem 'prawn_rails'
gem 'rqrcode'

# to render XLS spreadsheets
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'axlsx_rails'

# as error catcher
gem 'airbrake', '~> 7.1'

# to make links faster
gem 'turbolinks'

# for JSON serialization of our API
gem 'active_model_serializers'

# as icon font
gem 'font-awesome-rails'

# for markdown
gem 'redcarpet'

# as rdoc generator
gem 'rdoc-generator-fivefish'

# for visitor tracking
gem 'ahoy_matey'
gem 'piwik_analytics', '~> 1.0.1'

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
gem 'bootstrap-switch-rails', '~> 3.0.0'

# for parsing OEmbed data
gem 'ruby-oembed', '~>0.12.0'

# for uploading images to the cloud
gem 'cloudinary'

# for setting app configuration in the environment
gem 'dotenv-rails'

# configurable toggles for functionality
# https://github.com/mgsnova/feature
gem 'feature'

# For countable.js
gem "countable-rails", "~> 0.0.1"

# Both are not in a group as we use it also for rake data:demo
# for fake data
gem 'faker'
# for seeds
gem 'factory_girl_rails'

# for integrating Stripe payment gateway
gem 'stripe'

# Provides Sprockets implementation for Rails Asset Pipeline
gem 'sprockets-rails'

# for multiple speakers select on proposal/event forms
gem 'selectize-rails'

# For collecting performance data
gem 'skylight'

# Nokogiri < 1.8.1 is subject to:
# CVE-2017-0663, CVE-2017-7375, CVE-2017-7376, CVE-2017-9047, CVE-2017-9048,
# CVE-2017-9049, CVE-2017-9050
gem 'nokogiri', '>= 1.8.1'

# memcached binary connector
gem 'dalli'

# Use guard and spring for testing in development
group :development do
  # to launch specs when files are modified
  gem 'guard-rspec'
  gem 'haml_lint', '~> 0.24.0'
  gem 'spring-commands-rspec'
  # for static code analisys
  gem 'rubocop', '~> 0.51.0', require: false
  # as database
  gem 'sqlite3'
  # to open mails
  gem 'letter_opener'
  # to open mails in browser
  gem 'letter_opener_web'
  # as deployment system
  gem 'mina'
  # as debugger on error pages
  gem 'web-console', '~> 2.0'
end

group :test do
  # as test framework
  gem 'capybara'
  gem 'database_cleaner'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
  # for measuring test coverage
  gem 'coveralls', require: false
  # for describing models
  gem 'shoulda-matchers', require: false
  # for stubing/mocking models
  gem 'rspec-activemodel-mocks'
  # to freeze time
  gem 'timecop'
  # for mocking external requests
  gem 'webmock'
  # for mocking Stripe responses in tests
  gem 'stripe-ruby-mock'
  # For validating JSON schemas
  gem 'json-schema'
  # For using 'assigns' in tests
  gem 'rails-controller-testing'
  # For managing the environment
  gem 'climate_control'
  # parallel tests
  gem 'knapsack'
end

group :development, :test do
  # as debugger
  gem 'byebug'
end
