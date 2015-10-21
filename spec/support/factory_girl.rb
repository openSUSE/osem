RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.lint
  end
end
