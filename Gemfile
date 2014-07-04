source 'https://rubygems.org'

# Use rails as framework
gem 'rails', '~> 4.1'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use rails-observers for observing records
gem 'rails-observers'

# User paper_trail for tracking data changes
gem 'paper_trail'

# Use devise as authentification framework
gem 'devise'
# Use omniauth to support openID authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-openid'
gem 'omniauth-google-oauth2'

# Use cancan as authorization framework
gem 'cancan'

# Use transitions as state machine
gem 'transitions', :require => %w( transitions active_record/transitions )

# Use acts_as_commentable_with_threading for comments
gem 'awesome_nested_set', '~> 3.0.0.rc.5'
gem 'acts_as_commentable_with_threading'

# Use haml as templating language
gem 'haml-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use bootstrap as the front-end framework
gem 'bootstrap-sass'
gem 'formtastic-bootstrap'
gem 'formtastic', '~> 2.3.0.rc3'


# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails'
gem 'cocoon'

# Use gravtastic for user avatars
gem 'gravtastic'

# Use paperclip for upload management
gem 'paperclip'

# Use prawn as PDF generator
gem 'prawn_rails'

# Use axlsx_rails to render XLS spreadsheets
gem 'axlsx_rails'

# Use d3js for building our statistics
gem 'd3_rails'
gem 'chart-js-rails'

# Use a self-hosted errbit with the old notifier
gem 'hoptoad_notifier', '~> 2.3'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Use active_model_serializers for JSON serializatioin our API
gem 'active_model_serializers'

# Use FontAwesome for splash themes
gem 'font-awesome-rails'

#Use Redcarpet for Markdown in description
gem 'redcarpet'

# Rubyracer is JavaScript Runtime of choice
gem 'therubyracer'

# FIXME: We should use http://weblog.rubyonrails.org/2012/3/21/strong-parameters/
gem 'protected_attributes'

# We use this bootstrap/html5 rdoc generator
gem 'rdoc-generator-fivefish'

# We use factory_girl for seeds
gem 'factory_girl_rails'

# We use ahoy for visitor tracking
gem 'ahoy_matey'
gem 'activeuuid'

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
end

# Use rspec and capybara as testing framework
group :test do
  # We use coveralls for measuring test coverage
  gem 'coveralls', require: false
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'poltergeist'
  # Set of rails validations matchers to describe models
  gem 'shoulda'
end
