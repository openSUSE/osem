# frozen_string_literal: true

namespace :data do
  desc 'Create demo data using our factories'

  task demo: :environment do
    include FactoryBot::Syntax::Methods
    conference = create(:full_conference, title: 'Open Source Event Manager Demo', short_title: 'osemdemo' ,description: "This is a [Open Source Event Manager](http://osem.io/) demo instance. You can log in as **admin** with the password **password123** or just you just [sign up](/accounts/sign_up) with your own user. We hope you enjoy checking out all the functionality, if you have questions don't hesitate to [contact us](http://osem.io/#contact)!\r\n\r\n## Data will be destroyed every thirty minutes or whenever someone updates the [OSEM source code on github](https://github.com/openSUSE/osem/commits/master).")
    conference.contact.update(email: 'osemdemo@osem.io', sponsor_email: 'osemdemo@osem.io')
    create(:admin, email: 'admin@osem.io', username: 'admin', password: 'password123', password_confirmation: 'password123')
  end
end
