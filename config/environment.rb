# Load the rails application
require File.expand_path('../application', __FILE__)

# Load the configuration file
path = Rails.root.join('config', 'config.yml')
begin
  CONFIG = YAML.load_file(path)[Rails.env]
rescue
  puts "Error while parsing config file #{path}"
  CONFIG = {}
end

# Initialize the rails application
Osem::Application.initialize!
