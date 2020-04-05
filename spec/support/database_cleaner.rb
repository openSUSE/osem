# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    TransactionalCapybara::AjaxHelpers.wait_for_ajax(page) if example.metadata[:js]
    DatabaseCleaner.clean
  end
end
