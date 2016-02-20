RSpec.configure do |config|

  config.before(:suite) do
    FactoryGirl.lint if CONFIG['factory_girl_lint']
  end

end
