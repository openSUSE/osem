source 'https://rubygems.org'

# rails-assets requires >= 1.8.4
if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.8.4')
  abort "Bundler version >= 1.8.4 is required"
end

# as web framework
gem 'rails', '~> 4.2'

# enables serving assets in production and setting your logger to standard out
# both of which are required to run an application on a twelve-factor provider
# like heroku.com
gem 'rails_12factor', group: :production

# respond_to methods have been extracted to the responders gem
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#responders
gem 'responders', '~> 2.0'

# as the database for Active Record
gem 'mysql2'

# for observing records
gem 'rails-observers'

# for tracking data changes
gem 'paper_trail'

# for upload management
gem 'carrierwave'
gem 'mini_magick'
gem 'carrierwave-bombshelter'

# for internationalizing
gem 'rails-i18n', '~> 4.0.0'

# as authentification framework
gem 'devise'
gem 'devise_ichain_authenticatable'

# for openID authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'

# as authorization framework
gem 'cancancan'

# for roles
gem 'rolify'

# to show flash messages from ajax requests
gem 'unobtrusive_flash', '>=3'

# as state machine
gem 'transitions', :require => %w( transitions active_record/transitions )

# for comments
gem 'awesome_nested_set', '~> 3.0.0.rc.5'
gem 'acts_as_commentable_with_threading'

# as templating language
gem 'haml-rails'

# for stylesheets
gem 'sass-rails', '>= 4.0.2'

# as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# as the front-end framework
gem 'bootstrap-sass', '~> 3.3.4.1'
gem 'autoprefixer-rails'
gem 'formtastic-bootstrap'
gem 'formtastic', '~> 3.1.1'
gem 'cocoon'

# as the JavaScript library
gem 'jquery-rails'

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
  gem 'rails-assets-to-markdown'
  gem 'rails-assets-markdown'
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
gem 'prawn_rails'

# to render XLS spreadsheets
gem 'axlsx_rails'

# as error catcher
gem 'hoptoad_notifier', '~> 2.3'

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
gem 'activeuuid'
gem 'piwik_analytics', '~> 1.0.1'

# for recurring jobs
gem 'whenever', :require => false
gem 'delayed_job_active_record'

# to run scripts
gem 'daemons'

# to encapsulate money in objects
gem 'money-rails'

# for lists
gem 'acts_as_list'

# for switch checkboxes
gem 'bootstrap-switch-rails', '~> 3.0.0'

# for parsing OEmbed data
gem 'ruby-oembed'

# for uploading images to the cloud
gem 'cloudinary'

# for setting app configuration in the environment
gem 'dotenv-rails'

# Both are not in a group as we use it also for rake data:demo
# for fake data
gem 'faker'
# for seeds
gem 'factory_girl_rails'

# Use guard and spring for testing in development
group :development do
  # to launch specs when files are modified
  gem 'guard-rspec', '~> 4.2.8'
  gem 'spring-commands-rspec'
  # for static code analisys
  gem 'rubocop', require: false
  # to silence rack assests messages
  gem 'quiet_assets'
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
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
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
end

group :development, :test do
  # as debugger
  gem 'byebug'
end
