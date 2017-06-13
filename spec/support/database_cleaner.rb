RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.load_seed
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] == true ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean
    Rails.application.load_seed if example.metadata[:js] == true
  end
end
