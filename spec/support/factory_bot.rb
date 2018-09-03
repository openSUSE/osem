# frozen_string_literal: true

require_relative 'external_request'

RSpec.configure do |config|

  config.before(:suite) do
    if ENV['OSEM_FACTORY_LINT'] != 'false'
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      begin
        DatabaseCleaner.start
        mock_commercial_request
        FactoryBot.lint
      ensure
        DatabaseCleaner.clean
      end
    end
  end
end
