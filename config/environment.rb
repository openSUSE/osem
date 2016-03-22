# Load the rails application
require File.expand_path('../application', __FILE__)

# Load the configuration file
path = Rails.root.join('config', 'config.yml')
if File.exist?(path)
  puts "

WARNING: The OSEM configuration file

#{path}

is deprecated. Please use the environment environment variables
explained in INSTALL.md instead.


"
end

# Initialize the rails application
Osem::Application.initialize!
