RSpec.configure do |config|
config.before(:suite) do
    load "#{Rails.root}/db/seeds.rb" 
  end
end
