# frozen_string_literal: true

namespace :data do
  desc 'Create demo data using our factories'

  task demo: :environment do
    include FactoryBot::Syntax::Methods

    conference = create(:full_conference, title: 'Open Source Event Manager Demo', short_title: 'osemdemo' ,description: "This is an [Open Source Event Manager](http://osem.io/) demo instance. You can log in as **admin** with the password **password123** or you [sign up](/accounts/sign_up) as a user. We hope you enjoy checking out all the functionality, if you have questions do not hesitate to contact us on [IRC](https://web.libera.chat/#osem) or file an issue on [GitHub](https://github.com/openSUSE/osem).\r\n\r\n## Data will be destroyed every thirty minutes!")
    conference.contact.update(email: 'osemdemo@osem.io', sponsor_email: 'osemdemo@osem.io')
    create(:admin, email: 'admin@osem.io', username: 'admin', password: 'password123', password_confirmation: 'password123')
  end
end
