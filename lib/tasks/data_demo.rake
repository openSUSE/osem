namespace :data do
  desc 'Create demo data using our factories'
  task demo: :environment do
    include FactoryGirl::Syntax::Methods
    create(:full_conference)
    create(:admin, email: 'admin@osem.io', username: 'admin', password: 'password', password_confirmation: 'password')
  end
end
