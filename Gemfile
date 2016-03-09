source 'https://rubygems.org'

# rails-assets requires >= 1.8.4
if Gem::Version.new(Bundler::VERSION) < Gem::Version.new('1.8.4')
  abort "Bundler version >= 1.8.4 is required"
end

# as web framework
gem 'rails', '~> 4.2'

# respond_to methods have been extracted to the responders gem
# http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html#responders
gem 'responders', '~> 2.0'

# as the database for Active Record
gem 'mysql2'

# for observing records
gem 'rails-observers'

# for tracking data changes
gem 'paper_trail'

# as authentification framework
gem 'devise'
gem 'devise_ichain_authenticatable'

# to support openID authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'

# as authorization framework
gem 'cancancan'
# to set roles
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

# frontend javascripts

# as the JavaScript library
gem 'jquery-rails'

source 'https://rails-assets.org' do
  # for placeholder images
  gem 'rails-assets-holderjs'
  # for formating dates
  gem 'rails-assets-date.format'
  # for or parsing, validating, manipulating, and formatting dates.
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
  # for displaying maps
  gem 'rails-assets-leaflet'
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

# for user avatars
gem 'gravtastic'

# for country selects
gem 'country_select'

# for upload management
gem 'paperclip'

# as PDF generator
gem 'prawn_rails'

# to render XLS spreadsheets
gem 'axlsx_rails'

# as error catcher
gem 'hoptoad_notifier', '~> 2.3'

# to make links faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# for JSON serialization of our API
gem 'active_model_serializers'

# for icon fonts
gem 'font-awesome-rails'

# for Markdown in description
gem 'redcarpet'

# as rdoc generator
gem 'rdoc-generator-fivefish'

# for seeds
gem 'factory_girl_rails'

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

# Use guard and spring for testing in development
group :development do
  # rspec Guard rules
  gem 'guard-rspec', '~> 4.2.8'
  gem 'spring-commands-rspec'
  # Get HoundCi comments locally
  gem 'rubocop'
  # Silence rack assests messages
  gem 'quiet_assets'
  # Use sqlite3 as the database in development
  gem 'sqlite3'
  # Use letter_opener to open mails in development
  gem 'letter_opener'
  # Use letter_opener_web to open mails in browser (e.g. necessary for Vagrant)
  gem 'letter_opener_web'
  # mina is a blazing fast deployment system
  gem 'mina'
  gem 'web-console', '~> 2.0'
end

# Use rspec and capybara as testing framework
group :test do
  # We use coveralls for measuring test coverage
  gem 'coveralls', require: false
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  # Set of rails validations matchers to describe models
  gem 'shoulda-matchers', require: false
  # Extracted from RSpec 3 stub_model and mock_model
  gem 'rspec-activemodel-mocks'
  gem 'timecop'
  # for mocking external requests
  gem 'webmock'
end

group :development, :test do
  gem 'byebug'
end
