RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end
end
