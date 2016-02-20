require_relative 'external_request'

RSpec.configure do |config|

  config.before(:suite) do
    if CONFIG['factory_girl_lint']
      mock_commercial_request
      FactoryGirl.lint
    end
  end

end
