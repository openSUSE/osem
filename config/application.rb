require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Osem
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = ENV.fetch('OSEM_TIME_ZONE') { 'UTC' }
    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    config.active_record.sqlite3.represent_boolean_as_integer = false
    # Require `belongs_to` associations by default. Previous versions had false.
    config.active_record.belongs_to_required_by_default = false
  end
end
