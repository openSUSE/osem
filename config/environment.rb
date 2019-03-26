# Load the Rails application.
require_relative 'application'

# Load the configuration file
path = Rails.root.join('config', 'config.yml')
if File.exist?(path)
  puts "

WARNING: The OSEM configuration file

#{path}

is deprecated. Please use the environment variables
explained in INSTALL.md instead.

There is a rake task to migrate your settings. For instance
to migrate your settings for production:

bundle exec rake data:migrate:config2dotenv RAILS_ENV=production

"
end

# Initialize the Rails application.
Rails.application.initialize!
