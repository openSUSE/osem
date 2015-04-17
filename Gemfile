source 'https://rubygems.org'

# as web framework
gem 'rails', '~> 4.1'

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
gem 'formtastic', '~> 2.3.0.rc3'
gem 'momentjs-rails', '>= 2.8.1'
gem 'bootstrap3-datetimepicker-rails', '~> 3.0.2'

# as the JavaScript library
gem 'jquery-rails'
gem 'cocoon'
gem 'jquery-datatables-rails', '~> 2.2.1'

# for user avatars
gem 'gravtastic'

# for maps
gem 'leaflet-rails', '~> 0.7.4'

# for country selects
gem 'country_select', github: 'stefanpenner/country_select'

# for upload management
gem 'paperclip'

# as PDF generator
gem 'prawn_rails'

# to render XLS spreadsheets
gem 'axlsx_rails'

# for charts
gem 'd3_rails'
gem 'chart-js-rails'

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

# FIXME: We should use http://weblog.rubyonrails.org/2012/3/21/strong-parameters/
gem 'protected_attributes'

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
  # mina is a blazing fast deployment system
  gem 'mina'
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
  gem 'shoulda'
  # Extracted from RSpec 3 stub_model and mock_model
  gem 'rspec-activemodel-mocks'
  gem 'timecop'
end

group :development, :test do
  gem 'byebug'
end
