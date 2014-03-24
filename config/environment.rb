# Load the rails application
require File.expand_path('../application', __FILE__)

path = Rails.root.join("config", "config.yml")

begin
  CONFIG = YAML.load_file(path)[Rails.env]
rescue Exception
  puts "Error while parsing config file #{path}"
  CONFIG = Hash.new
end

# Initialize the rails application
Osem::Application.initialize!
